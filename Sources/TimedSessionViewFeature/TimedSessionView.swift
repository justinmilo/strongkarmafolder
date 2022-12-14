//
//  MeditationView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 3/16/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import SwiftUI
import Models
import PickerFeature
import UserNotifications
import Foundation
import UIKit
import ComposableUserNotifications
import CombineSchedulers
import ComposableArchitecture
import PrepViewFeature


public struct TimedSessionViewState: Equatable{
    public init(selType: Int = 0, selMin: Int = 0, types: [String] = [
        "Concentration",
        "Mindfullness of Breath",
        "See Hear Feel",
        "Self Inquiry",
        "Do Nothing",
        "Positive Feel",
        "Yoga Still",
        "Yoga Flow",
        "Shi-ne",
    ], timerData: TimerData? = nil, timedMeditation: Meditation? = nil, _tdcount: Int = 0) {
        self.selType = selType
        self.selMin = selMin
        self.types = types
        self.timerData = timerData
        self.timedMeditation = timedMeditation
    }
    
    let minutesList : [Double] = (1 ... 60).map(Double.init).map{$0}
    var selType : Int
    var selMin  : Int
    var types : [String]
    public var timerData : TimerData?
    public var timedMeditation: Meditation?
    var seconds  : Double { self.minutesList[self.selMin]
        * 60
    }
    var minutes  : Double { self.minutesList[self.selMin] }
    var currentType : String { self.types[self.selType]}
    var timerGoing: Bool { return  nil != timerData}
    var paused: Bool = false
}
    
public enum TimedSessionViewAction: Equatable {
    case addNotificationResponse(Result<Int, UserNotificationClient.Error>)
    case cancelButtonTapped
    case didFinishLaunching(notification: UserNotification?)
    case didReceiveBackgroundNotification(BackgroundNotification)
    case pauseButtonTapped
    case pickMeditationTime(Int)
    case pickTypeOfMeditation(Int)
    case remoteCountResponse(Result<Int, RemoteClient.Error>)
    case requestAuthorizationResponse(Result<Bool, UserNotificationClient.Error>)
    case startTimerPushed(duration:Double)
    case timerFired
    case timerFinished
    case userNotification(UserNotificationClient.Action)
}

public struct TimedSessionViewEnvironment {
    public init(remoteClient: RemoteClient, userNotificationClient: UserNotificationClient, mainQueue: AnySchedulerOf<DispatchQueue>, now: @escaping () -> Date, uuid: @escaping () -> UUID) {
        self.remoteClient = remoteClient
        self.userNotificationClient = userNotificationClient
        self.mainQueue = mainQueue
        self.now = now
        self.uuid = uuid
    }
    

    var remoteClient: RemoteClient
    public var userNotificationClient: UserNotificationClient
//   let scheduleNotification : (String, TimeInterval ) -> Void = { NotificationHelper.singleton.scheduleNotification(notificationType: $0, seconds: $1)
//   }
   var mainQueue: AnySchedulerOf<DispatchQueue>
   var now : ()->Date
   var uuid : ()->UUID
}

public let timedSessionReducer = Reducer<TimedSessionViewState, TimedSessionViewAction, TimedSessionViewEnvironment>{
    state, action, environment in
    struct TimerId: Hashable {}

    switch action {
    case let .didFinishLaunching(notification):

        return .merge(
          environment.userNotificationClient
            .delegate()
            .map(TimedSessionViewAction.userNotification),
          environment.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
            .catchToEffect()
            .map(TimedSessionViewAction.requestAuthorizationResponse)
          )
        
    case let .didReceiveBackgroundNotification(backgroundNotification):
        let fetchCompletionHandler = backgroundNotification.fetchCompletionHandler
        guard backgroundNotification.content == .countAvailable else {
          return .fireAndForget {
            backgroundNotification.fetchCompletionHandler(.noData)
          }
        }

        return environment.remoteClient.fetchRemoteCount()
          .catchToEffect()
          .handleEvents(receiveOutput: { result in
            switch result {
            case .success:
              fetchCompletionHandler(.newData)
            case .failure:
              fetchCompletionHandler(.failed)
            }
          })
          .eraseToEffect()
          .map(TimedSessionViewAction.remoteCountResponse)
        
    case .pickTypeOfMeditation(let index):
      state.selType = index
      return .none
      
    case .pickMeditationTime(let index) :
      state.selMin = index
      return .none
    case let .startTimerPushed(duration:seconds):
        state.timerData = TimerData(endDate: environment.now() + seconds)
      
      state.timedMeditation =  Meditation(id: environment.uuid(),
                        date: environment.now().description,
                        duration: seconds,
                        entry: "",
                                          title: state.currentType)

      let duration = state.timedMeditation!.duration
        let userActions = "User Actions"

        
        let content = UNMutableNotificationContent()
        content.title = "\(state.timedMeditation!.title) Complete"
        content.body = "Tap to add an entry"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell.caf"))
        content.badge = 1
        content.categoryIdentifier = userActions
        content.userInfo.updateValue(state.timedMeditation!.id.uuidString, forKey: "uuid-string")


        let request = UNNotificationRequest(
            identifier: "example_notification",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        )
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
         
        return  Effect.merge(
        Effect.timer(id: TimerId(), every: 1, on: environment.mainQueue)
          .map { _ in TimedSessionViewAction.timerFired },
        environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers(["example_notification"])
            .fireAndForget(),
        environment.userNotificationClient.add(request)
            .map(Int.init)
            .catchToEffect()
            .map(TimedSessionViewAction.addNotificationResponse),
        environment.userNotificationClient.setNotificationCategories([category])
            .fireAndForget()
     )
        
    case let .remoteCountResponse(.success(count)):
        return .none
        
    case .remoteCountResponse(.failure):
      return .none
        
    case .requestAuthorizationResponse:
      return .none
        
    case .timerFired:
        
        let currentDate = Date()
        
        guard let date = state.timerData?.endDate,
              currentDate < date,
              DateInterval(start: currentDate, end: date).duration >= 0 else {
                  return Effect(value: .timerFinished)
              }
        
        let seconds = DateInterval(start: currentDate, end: date).duration
        state.timerData?.timeLeft = seconds
        
        return .none
        
    case .timerFinished:
        state.timerData = nil
        return Effect.cancel(id: TimerId())
    case .addNotificationResponse(.success(let meint)):
        print("me int \(meint)")
        return .none
    case .addNotificationResponse(.failure(let error)):
        print(error)
        return .none
    case let .userNotification(.didReceiveResponse(response, completion)):
        let notification = UserNotification(userInfo: response.notification.request.content.userInfo())

        return .fireAndForget(completion)
    case .userNotification(.willPresentNotification(_, completion: let completion)):
        return .fireAndForget {
             completion([.list, .banner, .sound])
           }
    case .userNotification(.openSettingsForNotification(_)):
        return .none
    case .cancelButtonTapped:
        state.timerData = nil
        return Effect.merge(
            .cancel(id: TimerId()),
            environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers(["example_notification"])
                .fireAndForget()
            )
    case .pauseButtonTapped:
        switch state.paused {
        case false:
            state.paused = true
            return Effect.merge(
                .cancel(id: TimerId()),
                environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers(["example_notification"])
                    .fireAndForget()
                )
        case true:
            state.paused = false
            return Effect(value: .startTimerPushed(duration: state.timerData!.timeLeft!))
        }
        
    }
    
}

public struct TimedSessionView: View {
    public init(store: Store<TimedSessionViewState, TimedSessionViewAction>) {
        self.store = store
    }
    
    public var store: Store<TimedSessionViewState, TimedSessionViewAction>
    @State var myBool = true
  
    public var body: some View {
   WithViewStore( self.store ) { viewStore in
      VStack{
          Spacer()
          Text(viewStore.currentType)
              .font(.largeTitle)
          Spacer()
          Text(viewStore.timerData?.timeLeftLabel ?? "\(viewStore.minutes)")
            .foregroundColor(Color(#colorLiteral(red: 0.4843137264, green: 0.6065605269, blue: 0.9686274529, alpha: 1)))
            .font(.largeTitle)
          Group{
              Spacer()
              PrepView(goals: self.$myBool, motivation: self.$myBool, expectation: self.$myBool, resolve: self.$myBool, posture: self.$myBool)
              PickerFeature(
                types: viewStore.types,
                typeSelection:  viewStore.binding(
                    get: { $0.selType },
                    send: { .pickTypeOfMeditation($0) }
                ),
                minutesList: viewStore.minutesList,
                minSelection: viewStore.binding(
                    get: { $0.selMin },
                    send: { .pickMeditationTime($0) }
                ))
              Spacer()
              Spacer()
          }
        
          if !viewStore.timerGoing {
              Button(
                action: { viewStore.send(
                    .startTimerPushed(
                        duration: viewStore.seconds)
                )
                }) { Text("Start")
                        .font(.body)
                        .foregroundColor(.white)
                        .background(Circle()
                                        .frame(width: 66.0, height: 66.0, alignment: .center)
                                        .foregroundColor(.accentColor)
                                        .opacity(0.35)
                        )
                     }
          } else {
              HStack {
                  Spacer()
                  Button( action: { viewStore.send( .cancelButtonTapped ) })  { Text("Cancel")
                        .font(.body)
                        .foregroundColor(.white)
                        .background(Circle()
                                    .frame(width: 66.0, height: 66.0, alignment: .center)
                                    .foregroundColor(.secondary)
                                    .opacity(0.35)
                    )
                }
                  Spacer()
                  Spacer()
                  if (!viewStore.paused) {
                      Button( action: { viewStore.send( .pauseButtonTapped ) }) { Text("Pause")
                              .font(.body)
                              .foregroundColor(.white)
                              .background(Circle()
                                            .frame(width: 66.0, height: 66.0, alignment: .center)
                                            .foregroundColor(.accentColor)
                                            .opacity(0.35)
                              )
                        }
                  } else {
                      Button( action: { viewStore.send( .pauseButtonTapped ) }) { Text("Start")
                              .font(.body)
                              .foregroundColor(.white)
                              .background(Circle()
                                            .frame(width: 66.0, height: 66.0, alignment: .center)
                                            .foregroundColor(.accentColor)
                                            .opacity(0.35)
                              )
                        }
                  }
                  
                  Spacer()

              }
          }
          Spacer()
      }
   }
  }
}

struct MeditationView_Previews: PreviewProvider {
    static var previews: some View {

      Group {
      TimedSessionView(store: Store(
        initialState:
            TimedSessionViewState(),
         reducer: timedSessionReducer.debug(),
         environment: TimedSessionViewEnvironment(
            remoteClient: .randomDelayed,
            userNotificationClient: UserNotificationClient.live,
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            now: Date.init,
            uuid: UUID.init)
      )
      )

          TimedSessionView(store: Store(
            initialState:
                TimedSessionViewState(),
             reducer: timedSessionReducer.debug(),
             environment: TimedSessionViewEnvironment(
                remoteClient: .randomDelayed,
                userNotificationClient: UserNotificationClient.live,
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                now: Date.init,
                uuid: UUID.init)
          )
          )
         .environment(\.colorScheme, .dark)
    }
   }
}
