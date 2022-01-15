//
//  File.swift
//  
//
//  Created by Justin Smith on 1/6/22.
//

import Foundation
import ComposableArchitecture

public struct RemoteClient {
    public init(fetchRemoteCount: @escaping () -> Effect<Int, RemoteClient.Error>) {
        self.fetchRemoteCount = fetchRemoteCount
    }
    
  var fetchRemoteCount: () -> Effect<Int, Error>

  public struct Error: Swift.Error, Equatable {
    public init() {}
  }
}

extension RemoteClient {
  public static let randomDelayed = RemoteClient(
    fetchRemoteCount: {
      Effect(value: Int.random(in: 0...10))
        .delay(for: 2, scheduler: DispatchQueue.main)
        .eraseToEffect()
    }
  )
}
