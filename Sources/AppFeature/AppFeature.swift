
//
//  SceneDelegate.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/4/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import UIKit
import SwiftUI
import ListViewFeature

import ComposableArchitecture
import Foundation
import Models
import MeditationViewFeature
import ComposableUserNotifications
import Parsing
import ParsingHelpers

enum AppRoute {
  case list(ListRoute?)
}

//let deepLinker = PathComponent("one")
//    .take(inventoryDeepLinker2)
//    .map(AppRoute.one)
//  .orElse(
//    PathComponent("inventory")
//      .take(inventoryDeepLinker)
//      .map(AppRoute.inventory)
//  )
//  .orElse(
//    PathComponent("three")
//      .skip(PathEnd())
//      .map { .three }
//  )

let deepLinker = PathComponent("one")
    .take(listDeepLinker)
    .skip(PathEnd())
    .map{ AppRoute.list }
  

struct AppState : Equatable {
    var listViewState: ListViewState
}

enum AppAction : Equatable {
    case listAction(ListAction)
    case didFinishLaunching(notification: UserNotification?)
    case userNotification(UserNotificationClient.Action)
    case requestAuthorizationResponse(Result<Bool, UserNotificationClient.Error>)
    case open(URL)
}

struct AppEnvironment {
    var listEnv: ListEnv
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    listReducer.pullback(state: \.listViewState, action: /AppAction.listAction, environment: \AppEnvironment.listEnv),
    Reducer{ state, action, environment in
        
        switch action {
        case .listAction(_):
            return .none
        case .requestAuthorizationResponse:
            return .none
        case .didFinishLaunching(notification: let notification):
            
            return .merge(
                environment.listEnv.medEnv.userNotificationClient
                    .delegate()
                    .map(AppAction.userNotification),
                environment.listEnv.medEnv.userNotificationClient.requestAuthorization([.alert, .badge, .sound])
                    .catchToEffect()
                    .map(AppAction.requestAuthorizationResponse)
            )
        case let .userNotification(.didReceiveResponse(response, completion)):
            let notification = UserNotification(userInfo: response.notification.request.content.userInfo())
            
            return .fireAndForget(completion)
        case .userNotification(.willPresentNotification(_, completion: let completion)):
            return .fireAndForget {
                completion([.list, .banner, .sound])
            }
        case .userNotification(.openSettingsForNotification(_)):
            return .none
        case .open(let url):
            var request = DeepLinkRequest(url: url)
            if let route = deepLinker.parse(&request) {
              switch route {
              case let .list(inventoryRoute):
                  state.listViewState.navigate(to: inventoryRoute)
              }
            }
        }
    }
)
