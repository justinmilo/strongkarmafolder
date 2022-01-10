//
//  PrepView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 11/1/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

public struct PrepView: View {
    
    public init(
        goals: Binding<Bool>,
        motivation: Binding<Bool>,
        expectation: Binding<Bool>,
        resolve: Binding<Bool>,
        posture: Binding<Bool>
    ){
        self._showingGoals = goals
        self._showingMot = motivation
        self._showingExp = expectation
        self._showingRes = resolve
        self._showingPos = posture
    }
    
    @Binding public var showingGoals: Bool
    @Binding public var showingMot: Bool
    @Binding public var showingExp: Bool
    @Binding public var showingRes: Bool
    @Binding public var showingPos: Bool
    
    public var body: some View {
        HStack {
            Spacer()
            Group {
                PreperationView(showing: self.$showingGoals, text: "Goals")
                PreperationView(showing: self.$showingMot, text: "Motivation")
                PreperationView(showing: self.$showingExp, text: "Expectation")
                PreperationView(showing: self.$showingRes, text: "Resolve")
                PreperationView(showing: self.$showingPos, text: "Posture")
            }
        }
    }
}

struct PreperationView: View {
    
    @Binding var showing: Bool
    var text: String
    
    var body: some View {
        if showing {
            ZStack{
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .layoutPriority(1)
            }
                .onTapGesture {
                    
                }
                .onLongPressGesture(minimumDuration: 0.1) {
                    showing = false
                }
            Spacer()
        } else {
            ZStack(alignment: .bottom){
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .hidden()
                    .layoutPriority(1)
                Color(.sRGB, white: 0.95, opacity: 1)
                    .clipShape(Circle())
            }
                .onLongPressGesture(minimumDuration: 0.1) {
                    showing = true
                }
            Spacer()
        }
    }
}


struct PrepView_Previews: PreviewProvider {
    static var previews: some View {
        @State var showingGoals: Bool = true
        return PrepView(goals: $showingGoals, motivation: $showingGoals, expectation: $showingGoals, resolve: $showingGoals, posture: $showingGoals)
    }
}


struct TextFieldAlert<Presenting>: View where Presenting: View {
  
  @Binding var isShowing: Bool
  @Binding var text: String
  let presenting: Presenting
  let title: Text
  
  var body: some View {
    ZStack {
      presenting
        .disabled(isShowing)
      VStack {
        title
        TextField("hello", text: $text)
        Divider()
        HStack {
          Button(action: {
            withAnimation {
              self.isShowing.toggle()
            }
          }) {
            Text("Dismiss")
          }
        }
      }
      .padding()
      .background(Color.white)
      .relativeWidth(0.7)
      .relativeHeight(0.7)
      .shadow(radius: 1)
      .opacity(isShowing ? 1 : 0)
    }
  }
  
}


extension View {

    func textFieldAlert(isShowing: Binding<Bool>,
                        text: Binding<String>,
                        title: Text) -> some View {
        TextFieldAlert(isShowing: isShowing,
                       text: text,
                       presenting: self,
                       title: title)
    }

}

extension View {
    public func relativeHeight(
        _ ratio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                height: geometry.size.height * ratio,
                alignment: alignment
            )
        }
    }

    public func relativeWidth(
        _ ratio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * ratio,
                alignment: alignment
            )
        }
    }

    public func relativeSize(
        width widthRatio: CGFloat,
        height heightRatio: CGFloat,
        alignment: Alignment = .center
    ) -> some View {
        GeometryReader { geometry in
            self.frame(
                width: geometry.size.width * widthRatio,
                height: geometry.size.height * heightRatio,
                alignment: alignment
            )
        }
    }
}
