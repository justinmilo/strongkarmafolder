//
//  Current.swift
//  Strong Karma
//
//  Created by Justin Smith on 8/25/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import Foundation
import ComposableArchitecture
import Models

extension Meditation {
    static var dummy = Meditation(
        id: UUID(),
        date: "My Date",
        duration: 50,
        entry: "Some Entry",
        title:"Untitled"
    )
  static var dummy1 = Meditation(
      id: UUID(),
      date: "11/11/11",
      duration: 50,
      entry: "Mindfulness of Breath",
      title:"Untitled"
  )
  static var dummy2 = Meditation(
      id: UUID(),
      date: "12/12/12",
      duration: 50,
      entry: "A Journey In",
      title:"Untitled"
  )
}











