//
//  File.swift
//  
//
//  Created by Justin Smith on 1/6/22.
//

import ComposableArchitecture
import Models

extension IdentifiedArray where Element == Meditation, ID == UUID {
  mutating func removeOrAdd(meditation : Meditation) {
    guard let index = (self.firstIndex{ $0.id == meditation.id }) else {
      self.insert(meditation, at: 0)
      return
    }
    self[index] = meditation
  }
}
