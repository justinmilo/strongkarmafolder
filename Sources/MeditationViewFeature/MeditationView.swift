//
//  MeditationView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 3/16/20.
//  Copyright © 2020 Justin Smith. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import ComposableUserNotifications
import Models
import PickerFeature

public struct MediationViewState: Equatable{
    public init(selType: Int = 0, selMin: Int = 0, types: [String] = [
        "Concentration",
        "Mindfullness of Breath",
        "See Hear Feel",
        "Self Inquiry",
        "Do Nothing",
        "Positive Feel",
        "Yoga Still",
        "Yoga Flow",
        "Free Style",
    ], timerData: TimerData? = nil, timedMeditation: Meditation? = nil) {
        self.selType = selType
        self.selMin = selMin
        self.types = types
        self.timerData = timerData
        self.timedMeditation = timedMeditation
    }
    
    let minutesList : [Double] = (1 ... 60).map(Double.init).map{$0}
    var selType : Int = 0
    var selMin  : Int = 0
    var types : [String] = [
        "Concentration",
        "Mindfullness of Breath",
        "See Hear Feel",
        "Self Inquiry",
        "Do Nothing",
        "Positive Feel",
        "Yoga Still",
        "Yoga Flow",
        "Free Style",
      ]
    var timerData : TimerData?
    var timedMeditation: Meditation?
    var seconds  : Double { self.minutesList[self.selMin] * 60 }
    var minutes  : Double { self.minutesList[self.selMin] }
    var currentType : String { self.types[self.selType]}
}
    
public struct TimerData : Equatable {
 var endDate : Date
 var timeLeft : Double? { didSet {
   self.timeLeftLabel = formatTime(time: self.timeLeft ?? 0.0) ?? "Empty"
 }}
 var timeLeftLabel = ""
}

public enum MediationViewAction: Equatable {
    case pickMeditationTime(Int)
    case pickTypeOfMeditation(Int)
    case startTimerPushed(startDate:Date, duration:Double, type:String)
    case timerFired
    case timerFinished
    case addNotificationResponse(Result<Int, UserNotificationClient.Error>)
}

public struct MediationViewEnvironment {
    internal init(userNotificationClient: UserNotificationClient, mainQueue: AnySchedulerOf<DispatchQueue>, now: @escaping () -> Date, uuid: @escaping () -> UUID) {
        self.userNotificationClient = userNotificationClient
        self.mainQueue = mainQueue
        self.now = now
        self.uuid = uuid
    }
    
    var userNotificationClient: UserNotificationClient
//   let scheduleNotification : (String, TimeInterval ) -> Void = { NotificationHelper.singleton.scheduleNotification(notificationType: $0, seconds: $1)
//   }
   var mainQueue: AnySchedulerOf<DispatchQueue>
   var now : ()->Date
   var uuid : ()->UUID
}

public let mediationReducer = Reducer<MediationViewState, MediationViewAction, MediationViewEnvironment>{
    state, action, environment in
    struct TimerId: Hashable {}

    switch action {
    case .pickTypeOfMeditation(let index):
      state.selType = index
      return .none
      
    case .pickMeditationTime(let index) :
      state.selMin = index
      return .none
    case let .startTimerPushed(startDate: date, duration:seconds, type: type):
      state.timerData = TimerData(endDate: date+seconds)
      
      state.timedMeditation =  Meditation(id: environment.uuid(),
                        date: environment.now().description,
                        duration: seconds,
                        entry: "",
                        title: type)

      let duration = state.timedMeditation!.duration
        
        let content = UNMutableNotificationContent()
           content.title = "Example title"
           content.body = "Example body"

           let request = UNNotificationRequest(
             identifier: "example_notification",
             content: content,
             trigger: UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
           )

        
         
      return  Effect.concatenate(
        Effect.timer(id: TimerId(), every: 1, on: environment.mainQueue)
          .map { _ in MediationViewAction.timerFired },
        environment.userNotificationClient.removePendingNotificationRequestsWithIdentifiers(["example_notification"])
            .fireAndForget(),
        environment.userNotificationClient.add(request)
            .map(Int.init)
            .catchToEffect()
            .map(MediationViewAction.addNotificationResponse)
     )
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
    }
    
}

public struct MeditationView: View {
    public init(store: Store<MediationViewState, MediationViewAction>) {
        self.store = store
    }
    
    public var store: Store<MediationViewState, MediationViewAction>
  
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
          Button(
            action: { viewStore.send(
                .startTimerPushed(startDate:Date(), duration: viewStore.seconds, type: viewStore.currentType ))
          }) {
              Text("Start")
                  .font(.title)
          }
          Spacer()
      }
   }
  }
}

//struct MeditationView_Previews: PreviewProvider {
//    static var previews: some View {
//
//      Group {
//      MeditationView(store: Store(
//        initialState:
//            MediationViewState(
//                userData: UserData(meditations: IdentifiedArray(FileIO().load()), timedMeditationVisible: false )
//                ),
//         reducer: appReducer.debug(),
//         environment: AppEnvironment(
//            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
//            now: Date.init,
//            uuid: UUID.init
//         )
//         )
//      )
//
//
//      MeditationView(store: Store(
//        initialState: MediationViewState(
//            userData: UserData(meditations: IdentifiedArray(FileIO().load()), timedMeditationVisible: false )
//            ),
//         reducer: appReducer.debug(),
//         environment: AppEnvironment(
//            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
//            now: Date.init,
//            uuid: UUID.init
//         )
//         )
//      )
//         .environment(\.colorScheme, .dark)
//    }
//   }
//}
