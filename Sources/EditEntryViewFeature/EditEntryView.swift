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


public enum EditAction : Equatable {
    case didEditTitle(String)
    case didEditText(String)
}

public struct EditEnvironment {
    public init() { }
}

public let todoReducer = Reducer<Meditation, EditAction, EditEnvironment> { state, action, _ in
  switch action {
  case .didEditTitle(let text):
    state.title = text
     return .none

  case .didEditText(let text):
   state.entry = text
    return .none
  }
}


public struct EditEntryView: View {
    public init(store: Store<Meditation, EditAction>) {
        self.store = store
    }
    
  var store: Store<Meditation, EditAction>
  
  public var body: some View {
   
   WithViewStore(self.store) { viewStore in
      VStack{
         TextField("Title", text: viewStore.binding(
            get: { $0.title },
            send: { .didEditTitle($0) }
         ))
            .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 25))
            .font(.largeTitle)
         TextView(text: viewStore.binding(
            get: { $0.entry },
            send: { .didEditText($0) }
         ))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .padding(EdgeInsets(top: 5, leading: 25, bottom: 0, trailing: 25))
      }
   }
  
   }
}

