//
//  ContentView.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import AVFoundation
import Models
import MeditationViewFeature
import EditEntryViewFeature
import TimerBottomFeature
import TimedSessionViewFeature
import CasePaths


public struct ListViewState: Equatable {
    public init(meditations: IdentifiedArrayOf<Meditation>, addEntryPopover: Bool, meditationView: MediationViewState? = nil, collapsed: Bool, newMeditation: Meditation? = nil, addMeditationVisible: Bool) {
        self.meditations = IdentifiedArray( meditations.map{ EditState(meditation: $0, route:nil) } )
        self.addEntryPopover = addEntryPopover
        self.meditationView = meditationView
        self.collapsed = collapsed
        self.addMeditationVisible = addMeditationVisible
    }
    
    var meditations : IdentifiedArrayOf<EditState>
    var meditationsReversed: IdentifiedArrayOf<EditState> {
      IdentifiedArrayOf<EditState>( self.meditations.reversed() )
    }
    var addEntryPopover : Bool
    var meditationView: MediationViewState?
    var collapsed: Bool
  var addMeditationVisible: Bool
    var route: Route?
    var timerBottomState: TimerBottomState?{
        get{
            guard let meditationView = self.meditationView else { return nil }
            
            return TimerBottomState(timerData: meditationView.timerData, timedMeditation: meditationView.timedMeditation, enabled: true)
            }
        set{
            if let newValue = newValue {
                self.meditationView!.timerData = newValue.timerData
                self.meditationView!.timedMeditation = newValue.timedMeditation
            }
        }
    }
    
       // .navigate(to: inventoryRoute)
    
    
    public enum Route: Equatable {
      case timedSession(TimedSessionViewState)
    }
}

public enum ListAction: Equatable{
    case addButtonTapped
    case addMeditationDismissed
    case deleteMeditationAt(IndexSet)
    case dismissEditEntryView
    case edit(id: UUID, action: EditAction)
    case editNew(EditAction)
    case meditation(MediationViewAction)
    case presentTimedMeditationButtonTapped
    case saveData
    case timerBottom(TimerBottomAction)
}

public struct ListEnv{
    public init(file: FileClient, uuid: @escaping () -> UUID, now: @escaping () -> Date, medEnv: MediationViewEnvironment) {
        self.file = file
        self.uuid = uuid
        self.now = now
        self.medEnv = medEnv
    }
    
    var file: FileClient
    var uuid : ()->UUID
    var now : ()->Date
    public var medEnv: MediationViewEnvironment
}

public let listReducer = Reducer<ListViewState, ListAction, ListEnv>.combine(
    todoReducer.forEach(state: \.meditations, action: /ListAction.edit(id:action:), environment: { _ in EditEnvironment()}),
    mediationReducer.optional().pullback(state: \.meditationView, action: /ListAction.meditation, environment: { global in global.medEnv }),
    Reducer{ state, action, environment in
        switch action {
        case .addButtonTapped:
            state.addMeditationVisible = true
            let med = Meditation(id: environment.uuid(),
                                 date: environment.now().description,
                                 duration: 300,
                                 entry: "",
                                 title: "Untitled")
            state.newMeditation = med
            return .none
            
        case .addMeditationDismissed:
            let transfer = state.newMeditation!
            state.newMeditation = nil
            state.meditations.removeOrAdd(meditation: transfer)
            state.addMeditationVisible = false
            
            return Effect(value: .saveData)
            
        case .deleteMeditationAt(let indexSet):
            // Set comes in reversed
            let reversedSet : IndexSet = IndexSet(indexSet.reversed())
            state.meditations.remove(atOffsets: reversedSet)
            
             return .none
            
        case .dismissEditEntryView:
            state.collapsed = true
            return Effect(value: .saveData)
            
        case .edit(id: _, action: _):
            return .none
            
        case .editNew(.didEditText(let string)):
            state.newMeditation!.entry = string
            return .none

        case .editNew(.didEditTitle(let string)):
            state.newMeditation!.title = string
            return .none
            
        case .meditation(.timerFinished):
            let tempMed = state.meditationView!.timedMeditation!
            state.meditationView!.timedMeditation = nil
            state.meditations.removeOrAdd(meditation: tempMed)
            
            return .none
            
        case .meditation(_):
            return .none

        case .presentTimedMeditationButtonTapped:
              state.collapsed = false
              state.meditationView = MediationViewState()
            return .none
            
        case .saveData:
            let meds = state.meditations
            
            return
              Effect.fireAndForget {
                 environment.file.save(Array(meds))
            }
        case .timerBottom(.buttonPressed):
            state.collapsed = false
            return .none
        }
    }
)


public struct ListView : View {
    public init(store: Store<ListViewState, ListAction>) {
        self.store = store
    }
    

  var store: Store<ListViewState, ListAction>
  @State private var timerGoing = true
  
  public var body: some View {
   WithViewStore(self.store) { viewStore in
      VStack {
          NavigationView {
            List {
               ForEachStore( self.store.scope(
                  state: { $0.meditations },
                  action: ListAction.edit(id:action:)) )
               { meditationStore in
                     NavigationLink(destination:
                        EditEntryView.init(store:meditationStore)
                           .onDisappear {
                              viewStore.send(.saveData)
                        }){
                        ListItemView(store: meditationStore)
                     }
                  
              }
               .onDelete { (indexSet) in
                  viewStore.send(.deleteMeditationAt(indexSet))
               }
               
              Text("Welcome the arrising, see it, let it through")
                .lineLimit(3)
                .padding()
            }
            .navigationBarTitle(Text("Strong Karma"))
            .navigationBarItems(trailing:
              Button(action: {
                viewStore.send(.addButtonTapped)
              }){
              Circle()
                .frame(width: 33.0, height: 33.0, alignment: .center)
                .foregroundColor(.secondary)
            })
          }
          .sheet(item: viewStore.route.case(/ListViewState.Route.timedSession)) { itemToAdd in
              NavigationView {
                ItemView(viewModel: itemToAdd)
                  .navigationTitle("Add")
                  .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                      Button("Cancel") { self.viewModel.cancelButtonTapped() }
                    }
                    ToolbarItem(placement: .primaryAction) {
                      Button("Save") { self.viewModel.add(item: itemToAdd.item) }
                    }
                  }
              }
          
          if (viewStore.collapsed){
              IfLetStore(
                self.store.scope(
                    state: { $0.timerBottomState },
                    action: ListAction.timerBottom),
                then: { newStore in
                    TimerBottom(store: newStore)
                },
                else:
                    Button(action: {
                        viewStore.send(ListAction.presentTimedMeditationButtonTapped)
                    }){
                        Circle()
                            .frame(width: 44.0, height: 44.0, alignment: .center)
                            .foregroundColor(.secondary)
                    }
              )
          } else {
             
          }
//
        Text("")
          .hidden()
          .sheet(
            isPresented: viewStore.binding(
              get:  { !$0.collapsed },
              send:  { _ in ListAction.dismissEditEntryView }
            )
          ) {
              IfLetStore(
                self.store.scope(
                    state: { $0.meditationView },
                    action: ListAction.meditation),
                then: { newStore in
                    MeditationView(store: newStore)
                }
              )
          }
//
        Text("")
          .hidden()
          .sheet(
            isPresented: viewStore.binding(
              get:  { $0.addMeditationVisible },
              send:  { _ in

                print("isPresented send")

                return ListAction.addMeditationDismissed

              }
            )
          ) {
            IfLetStore( self.store.scope(
                          state: {_ in viewStore.newMeditation },
                          action: { return ListAction.editNew($0)}),
                        then: { store in
                          EditEntryView.init(store: store)
                        },
                        else: Text("Nothing here")
            )

      }
      .edgesIgnoringSafeArea(.bottom)
   }
  }
}
}






