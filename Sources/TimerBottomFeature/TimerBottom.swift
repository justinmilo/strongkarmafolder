//
//  TimerBottom.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 3/28/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Models
import TimedSessionViewFeature

//public struct TimerBottomState {
//    public init(timerData: TimerData? = nil, timedMeditation: Meditation? = nil, enabled: Bool) {
//        self.timerData = timerData
//        self.timedMeditation = timedMeditation
//        self.enabled = enabled
//    }
//
//  public var timerData : TimerData?
//  public var timedMeditation : Meditation? = nil
//  var enabled : Bool
//}

public struct TimerBottom : View {
    public init(store: Store<TimedSessionViewState, ()>) {
        self.store = store
    }
    
  struct State : Equatable {
    var timeLeftLabel : String
    var meditationTitle : String
  }
  
  var store: Store<TimedSessionViewState, ()>


  public var body: some View {
      WithViewStore(
        self.store.scope(
            state: { TimerBottom.State(timerBottomState: $0) }
        ),
        content: { viewStore in
            VStack {
                    HStack {
                      Spacer()
                      Text(viewStore.timeLeftLabel)
                        .font(.title)
                        .foregroundColor(.accentColor)
                      Spacer()
                    }
                    HStack {
                      Spacer()
                      Text(viewStore.meditationTitle)
                          .foregroundColor(.secondary)
                      Spacer()
                    }
                  }
                  .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
            
                  .background(
                    LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
                      .opacity(/*@START_MENU_TOKEN@*/0.413/*@END_MENU_TOKEN@*/)
                  )
      }
    )
  }
}
//
//
//      VStack {
//        HStack {
//          Spacer()
//          Text(viewStore.timeLeftLabel)
//            .font(.title)
//            .foregroundColor(.accentColor)
//          Spacer()
//        }
//        HStack {
//          Spacer()
//          Text(viewStore.meditationTitle)
//              .foregroundColor(.secondary)
//          Spacer()
//        }
//      }
//      .padding(EdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0))
//
//      .background(
//        LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
//          .opacity(/*@START_MENU_TOKEN@*/0.413/*@END_MENU_TOKEN@*/)
//      )
//    }
//  }
//   }
//}

extension TimerBottom.State {
  init (timerBottomState : TimedSessionViewState){
    self.meditationTitle = timerBottomState.timedMeditation?.title ?? ""
    self.timeLeftLabel = timerBottomState.timerData?.timeLeftLabel ?? ":"
  }
}

