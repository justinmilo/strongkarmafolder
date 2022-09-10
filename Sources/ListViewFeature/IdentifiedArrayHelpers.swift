//
//  File.swift
//  
//
//  Created by Justin Smith on 1/6/22.
//

import ComposableArchitecture
import Models

extension IdentifiedArray where Element: Identifiable, ID == UUID {
public  mutating func removeOrAdd(item : Element) {
      guard let index = (self.firstIndex{ $0.id as! UUID == item.id as! UUID }) else {
      self.insert(item, at: 0)
      return
    }
    self.update(item, at: index)
  }
}

extension IdentifiedArray where Element: Identifiable, ID == UUID {
  public func element(id : ID) -> Element? {
      guard let index = (self.firstIndex{ $0.id as! UUID == id }) else {
          return nil
    }
      return self[index]
  }
}

