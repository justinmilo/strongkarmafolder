//
//  File.swift
//  
//
//  Created by Justin Smith on 1/6/22.
//

import Foundation

public struct TimerData : Equatable {
    public init(endDate: Date, timeLeft: Double? = nil, timeLeftLabel: String = "") {
        self.endDate = endDate
        self.timeLeft = timeLeft
        self.timeLeftLabel = timeLeftLabel
    }
    
 var endDate : Date
 var timeLeft : Double? { didSet {
   self.timeLeftLabel = formatTime(time: self.timeLeft ?? 0.0) ?? "Empty"
 }}
 public var timeLeftLabel = ""
}
