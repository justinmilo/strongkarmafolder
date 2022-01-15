//
//  SwiftUIView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/26/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Models

public struct EditState: Equatable, Identifiable {
    public init(meditation: Meditation, route: EditState.Route? = nil) {
        self.meditation = meditation
        self.route = route
    }
    
    public var id: Meditation.ID { self.meditation.id }
    public var meditation: Meditation
    public var route: Route?
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(self.meditation.id)
    }
    
    public enum Route: Equatable {
    }
}

public enum EditAction : Equatable {
    case didEditTitle(String)
    case didEditText(String)
}

public struct EditEnvironment {
    public init() { }
}

public let todoReducer = Reducer<EditState, EditAction, EditEnvironment> { state, action, _ in
  switch action {
  case .didEditTitle(let text):
      state.meditation.title = text
     return .none

  case .didEditText(let text):
    state.meditation.entry = text
    return .none
  }
}


public struct EditEntryView: View {
    public init(store: Store<EditState, EditAction>) {
        self.store = store
    }
    
  var store: Store<EditState, EditAction>
  
  public var body: some View {
   
   WithViewStore(self.store) { viewStore in
      VStack{
         TextField("Title", text: viewStore.binding(
            get: { $0.meditation.title },
            send: { .didEditTitle($0) }
         ))
            .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 25))
            .font(.largeTitle)
         TextView(text: viewStore.binding(
            get: { $0.meditation.entry },
            send: { .didEditText($0) }
         ))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding(EdgeInsets(top: 5, leading: 25, bottom: 0, trailing: 25))
      }
   }
  
   }
}

