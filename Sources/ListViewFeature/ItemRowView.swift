//
//  EntryCellView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Models
import EditEntryViewFeature
import TCAHelpers
import SwiftUIHelpers

public struct ItemRowState: Equatable, Identifiable {
    public var id: Meditation.ID { item.id }
    
    public var item: Meditation
    public var route: Route?
    public enum Route: Equatable {
      case deleteAlert
      case edit(EditState)
    }
}

public enum ItemRowAction: Equatable {
    case edit(EditAction)
    case setEditNavigation(isActive: Bool)
}

public struct ItemRowEnvironment {
}

public let itemRowReducer = Reducer<ItemRowState, ItemRowAction, ItemRowEnvironment>.combine(
    todoReducer.pullback(state: OptionalPath(\ItemRowState.route)
                            .appending(path: OptionalPath(/ItemRowState.Route.edit)),
                        action: /ItemRowAction.edit,
                        environment: { _ in EditEnvironment()}),
    Reducer{ state, action, environment in
        switch action {
        case .edit(.didEditText( let text)):
            state.item.entry = text
            return .none
        case .edit(.didEditTitle( let text)):
            state.item.title = text
            return .none
        case .setEditNavigation(isActive: let isActive):
            switch isActive {
            case true:
                state.route = .edit(EditState(meditation: state.item, route: nil))
            case false:
                state.route = nil
            }
            return .none
        }
    }
)

struct ItemRowView : View {
   var store: Store<ItemRowState,ItemRowAction>
  
  var body : some View {
   WithViewStore(self.store) { viewStore in
       NavigationLink(
        unwrap: Binding(get: { viewStore.route }, set: { _ in }),
        case: /ItemRowState.Route.edit,
        onNavigate: { viewStore.send(.setEditNavigation(isActive: $0)) },
        destination: { itemViewModel in
            IfLetStore<EditState, EditAction, EditEntryView?>(
                self.store.scope(
                  state: { state in
                      guard case .edit(let s) = state.route else {
                          return nil
                      }
                      return s
                      
                  },
                  action: { .edit($0) }
                ),
                then: { EditEntryView( store: $0 )
                }
              )
        }
       ) {
                  VStack(alignment: HorizontalAlignment.leading, spacing: nil) {
                      HStack{
                          Text(viewStore.item.title)
                          Spacer()
                          Text(viewStore.item.durationFormatted ?? "Empty")
                              .font(.footnote)
                              .foregroundColor(.gray)
       
                      }
                      date(from:viewStore.item.date).map{
                          Text(formattedDate(from: $0))
                              .foregroundColor(.gray)
                      }
                      if viewStore.item.entry != "" {
                          Spacer()
                          Text(viewStore.item.entry)
                              .foregroundColor(.gray)
                      }
                      Spacer()
                  }
          }
       
       
       
       
   }
//      NavigationLink(destination:
//         EditEntryView.init(store:meditationStore)
//            )
//      viewStore in
//       NavigationLink(Bernard Arnault
//         unwrap: viewStore.route,
//         case: /ItemRowState.Route.edit,
//         onNavigate: viewStore.send(.setEditNavigation(isActive:)),
//         destination: { itemViewModel in
//           EditEntryView(store: <#T##Store<EditState, EditAction>#>)
//
//         }
//
//       ){
//           VStack(alignment: HorizontalAlignment.leading, spacing: nil) {
//               HStack{
//                   Text(viewStore.meditation.title)
//                   Spacer()
//                   Text(viewStore.meditation.durationFormatted ?? "Empty")
//                       .font(.footnote)
//                       .foregroundColor(.gray)
//
//               }
//               date(from:viewStore.meditation.date).map{
//                   Text(formattedDate(from: $0))
//                       .foregroundColor(.gray)
//               }
//               if viewStore.meditation.entry != "" {
//                   Spacer()
//                   Text(viewStore.meditation.entry)
//                       .foregroundColor(.gray)
//               }
//               Spacer()
//           }
//   }
//   }
  }
}

//
//struct EntryCellView_Previews: PreviewProvider {
//    static var previews: some View {
//      ListItemView(store: Meditation.dummy)
//    }
//}
