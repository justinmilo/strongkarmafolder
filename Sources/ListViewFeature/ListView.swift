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
import EditEntryViewFeature
import SwiftUIHelpers
import TimerBottomFeature
import TimedSessionViewFeature
import CasePaths
import Foundation
import TCAHelpers

public struct ListViewState: Equatable {
    public init(meditations: IdentifiedArrayOf<Meditation>,
                route: Route?) {
        self.meditations = IdentifiedArray( meditations.map{ EditState(meditation: $0, route:nil) } )
        self.route = route
    }
    
    var meditations : IdentifiedArrayOf<EditState>
    var meditationsReversed: IdentifiedArrayOf<EditState> {
        IdentifiedArrayOf<EditState>( self.meditations.reversed() )
    }
    var route: Route?
    public enum Route: Equatable {
        case open(TimedSessionViewState)
        case closed(TimedSessionViewState?, Route2?)
        public enum Route2: Equatable {
            case edit(EditState)
            case add(EditState)
        }
    }
    // _timed
    //        .--Open--
    //         --collapsed--
    //              --EditEntry--
    //              --AddEntry--
    // (None)
    //              --EditEntry--
    //              --AddEntry--
    //
    // _timed
    //  --EditEntry--
    //
    //
    //           --AddEntry--
    //
    //              --EditEntry--
    //              --AddEntry--
    //

    var timedSession: TimedSessionViewState? {
        switch self.route {
        case .open(let sessionState):
            return sessionState
        case .closed(let t, _):
            return t
        case .none:
            return nil
        }
    }
    
    var collapsed: Bool {
        guard let _ = self.timedSession else { return false }
        guard case .open = self.route else { return false }
        return true
    }
}

public enum ListAction: Equatable{
    case addButtonTapped
    case addMeditationDismissed
    case deleteMeditationAt(IndexSet)
    case dismissEditEntryView
    case edit(id: UUID, action: EditAction)
    case editNew(EditAction)
    case meditation(TimedSessionViewAction)
    case presentTimedMeditationButtonTapped
    case setSheet(isPresented: Bool)
    case saveData
    case timerBottomBarPushed
}

public struct ListEnv{
    public init(file: FileClient, uuid: @escaping () -> UUID, now: @escaping () -> Date, medEnv: TimedSessionViewEnvironment) {
        self.file = file
        self.uuid = uuid
        self.now = now
        self.medEnv = medEnv
    }
    
    var file: FileClient
    var uuid : ()->UUID
    var now : ()->Date
    public var medEnv: TimedSessionViewEnvironment
}

public let listReducer = Reducer<ListViewState, ListAction, ListEnv>.combine(
    todoReducer.forEach(state: \.meditations, action: /ListAction.edit(id:action:), environment: { _ in EditEnvironment()}),
//    mediationReducer.pullback(
//        state: OptionalPath(\ListViewState.route)
//            .appending(path: OptionalPath(/ListViewState.Route.open)),
//        action: /ListAction.meditation,
//        environment: { global in global.medEnv }),
//    mediationReducer.pullback(
//        state: OptionalPath(\ListViewState.route)
//            .appending(
//                path: OptionalPath(/ListViewState.Route.closed)
//                    .appending(
//                        path: OptionalPath(extract: { root in
//                            root.0
//                            
//                        }, set: { (root, value) in
//                            root.0 = value
//                        })
//                    )
//            ),
//        action: /ListAction.meditation,
//        environment: { global in global.medEnv }),
    Reducer{ state, action, environment in
        switch action {
        case .addButtonTapped:
            let med = Meditation(id: environment.uuid(),
                                 date: environment.now().description,
                                 duration: 300,
                                 entry: "",
                                 title: "Untitled")
            state.route = .closed(state.timedSession, .add(EditState(meditation: med, route: nil)
                                                          )
            )
            return .none
            
        case .addMeditationDismissed:
            guard case .open(let miniState) = state.route else { fatalError() }
            state.route = .closed(miniState, nil)
            
            return Effect(value: .saveData)
            
        case .deleteMeditationAt(let indexSet):
            // Set comes in reversed
            let reversedSet : IndexSet = IndexSet(indexSet.reversed())
            state.meditations.remove(atOffsets: reversedSet)
            
             return .none
            
        case .dismissEditEntryView:
            state.route = nil
            return Effect(value: .saveData)
            
        case .edit(id: _, action: _):
            return .none
            
        case .editNew(.didEditText(let string)):
            let ses = state.timedSession
            
//
//            state.route = .closed(state.timedSession, .add(EditState(meditation: med, route: nil)
//                                                          )
//            )
            return .none
            
//
//            guard case .closed(_, .edit(let state)) = state.route
//            else { fatalError() }
//            state.meditation.entry = string
//            state.route = .editEntry(editStateM)
//            return .none

        case .editNew(.didEditTitle(let string)):
//            guard case .editEntry(let editState) = state.route
//            else { fatalError() }
//            var editStateM = editState
//            editStateM.meditation.title = string
//            state.route = .editEntry(editStateM)
//
            return .none
            
        case .meditation(.timerFinished):
            
            guard let timedState = state.timedSession
            else { fatalError() }
            
            let edit = EditState(meditation: timedState.timedMeditation!, route: nil)

            state.meditations.removeOrAdd(item: edit)
            
            return .none
            
        case .meditation(_):
            return .none

        case .presentTimedMeditationButtonTapped:
            state.route = .open(TimedSessionViewState())
            return .none
            
        case .saveData:
            let meds = state.meditations
            
            return
              Effect.fireAndForget {
                  environment.file.save(Array(meds.map{ $0.meditation }))
            }
        case .timerBottomBarPushed:
            state.route = .open(state.timedSession!)
            return .none
        case .setSheet(isPresented: let isPresented):
            state.route = .closed(state.timedSession, nil)
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
          .sheet(
            isPresented: viewStore.binding(
                get: { (listViewState: ListViewState)-> Bool  in
                    guard case .open = listViewState.route else {
                        return false
                    }
                    return true
                },
              send: ListAction.setSheet(isPresented:)
            )
          ) {
              IfLetStore(self.store.scope(
                state: { state in
                    guard case .open(let sessionState) = state.route else {
                        return nil
                    }
                    return sessionState
                    
                },
                action: { local in
                    ListAction.meditation(local)
                }),
                         then:TimedSessionView.init(store:)
              )
          }
          
          if (viewStore.collapsed){
              IfLetStore(
                self.store.scope(
                    state: { $0.timedSession! },
                    action: { _ in fatalError() }
                ),
                then: { newStore in
                    VStack {
                        TimerBottom(store: newStore)
                            .onTapGesture(perform: {viewStore.send(ListAction.timerBottomBarPushed)})
                    }
                },
                else:
                    Button(action: {
                        viewStore.send(ListAction.presentTimedMeditationButtonTapped)
                    }){
                        Text("HEYA2")
                        Circle()
                            .frame(width: 44.0, height: 44.0, alignment: .center)
                            .foregroundColor(.secondary)
                    }
              )
          } else {
              Button(action: {
                  viewStore.send(ListAction.presentTimedMeditationButtonTapped)
              }){
                  Circle()
                      .frame(width: 44.0, height: 44.0, alignment: .center)
                      .foregroundColor(.secondary)
              }
          }
////
//        Text("")
//          .hidden()
//          .sheet(
//            isPresented: viewStore.binding(
//              get:  { !$0.collapsed },
//              send:  { _ in ListAction.dismissEditEntryView }
//            )
//          ) {
//              IfLetStore(
//                self.store.scope(
//                    state: { $0.meditationView },
//                    action: ListAction.meditation),
//                then: { newStore in
//                    MeditationView(store: newStore)
//                }
//              )
//          }
////
//        Text("")
//          .hidden()
//          .sheet(
//            isPresented: viewStore.binding(
//              get:  { $0.addMeditationVisible },
//              send:  { _ in
//
//                print("isPresented send")
//
//                return ListAction.addMeditationDismissed
//
//              }
//            )
//          ) {
//            IfLetStore( self.store.scope(
//                          state: {_ in viewStore.newMeditation },
//                          action: { return ListAction.editNew($0)}),
//                        then: { store in
//                          EditEntryView.init(store: store)
//                        },
//                        else: Text("Nothing here")
//            )
//
//      }
//      .edgesIgnoringSafeArea(.bottom)
   }
  }
}
}





