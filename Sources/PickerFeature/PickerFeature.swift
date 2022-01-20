//
//  File.swift
//  
//
//  Created by Justin Smith on 1/1/22.
//

import Foundation
import SwiftUI


public struct PickerFeature: View {
    var types: [String]
    @Binding var typeSelection: Int
    var minutesList: [Double]
    @Binding var minSelection: Int
    
    public init(
        types: [String],
        typeSelection: Binding<Int>,
        minutesList: [Double],
        minSelection: Binding<Int>){
            self.types = types
            self._typeSelection = typeSelection
            self.minutesList = minutesList
            self._minSelection = minSelection
    }

    public var body: some View {
        VStack{
        Picker("Type", selection: $typeSelection){
            ForEach(0 ..< types.count) { index in
                Text(types[index]).tag(index)
            }
        }
        .labelsHidden()
        .pickerStyle(.wheel)
        Picker("Min", selection: $minSelection) {
            ForEach(0 ..< minutesList.count) {
                Text( String( minutesList[$0] )
                ).tag($0)
            }
        }
        .labelsHidden()
        .pickerStyle(.wheel)
        }
    }
}
