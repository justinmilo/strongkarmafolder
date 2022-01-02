//
//  NotificationHelper.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 11/6/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import UserNotifications
import ComposableArchitecture

extension Notification.Name {
   static let MeditationNotification = Notification.Name("MeditationNotification")
}


final class NotificationHelper : NSObject, UNUserNotificationCenterDelegate {
  
  static let singleton = NotificationHelper()
  
  var store: Store<AppState, AppAction>?
   var viewStore: ViewStore<AppState, AppAction>?
  
  override init() {
    let options: UNAuthorizationOptions = [.alert, .sound, .badge]
    notificationCenter.requestAuthorization(options: options) {
        (didAllow, error) in
        if !didAllow {
            print("User has declined notifications")
        }
    }
    
    notificationCenter.getNotificationSettings { (settings) in
      if settings.authorizationStatus != .authorized {
        print("notifications are not authroized")
      }
      else {
        print("notifications are!! authorized")
      }
    }
    super.init()
    
  }
  
  let notificationCenter = UNUserNotificationCenter.current()
   
  func scheduleNotification(notificationType: String, seconds: TimeInterval ) {
        
     let content = UNMutableNotificationContent()
     let userActions = "User Actions"
     
     content.title = notificationType
     content.body = "This is example how to create " + notificationType
     content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "bell.caf"))
     content.badge = 1
     content.categoryIdentifier = userActions
     
     let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
     let identifier = "Local Notification"
     let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
     
     notificationCenter.add(request) { (error) in
       if let error = error {
         print("Error \(error.localizedDescription)")
       }
     }
     
     let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
     let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete", options: [.destructive])
     let category = UNNotificationCategory(identifier: userActions, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
     
     notificationCenter.setNotificationCategories([category])
   }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.alert, .sound])
    print ("userNotificationHere")
   self.viewStore?.send(.notification(.willPresentNotification))
    }
   
   func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
   
   }
   
   func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    self.viewStore?.send(.notification(.didRecieveResponse))
    completionHandler()
   }
}
