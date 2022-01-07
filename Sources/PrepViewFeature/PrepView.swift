//
//  PrepView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 11/1/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI

struct PrepView: View {
    
    @State private var showingGoals = false
    @State private var showingMot = false
    @State private var showingExp = false
    @State private var showingRes = false
    @State private var showingPos = false
    
    @State private var goalInput = ""
    @State private var motInput = ""
    @State private var expInput = ""
    @State private var resInput = ""
    @State private var posInput = ""
    
    var body: some View {
        HStack {
            Spacer()
            Group {
                
                Button(action: {self.showingGoals = true} ) {
                    VStack {
                        Text("Goals")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(goalInput)
                    }
                }
                Spacer()
                
                VStack {
                    Button(action: {self.showingExp = true} ) {
                        VStack {
                            Text("Motivation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(motInput)
                        }
                    }
                    
                    
                }
                Spacer()
                
                VStack {
                    Text("Expectation")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: {} ) {
                        Text(expInput)
                    }
                }
                Spacer()
                
                VStack {
                    Text("Resolve")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: {} ) {
                        Text(resInput)
                    }
                }
                Spacer()
                
                VStack {
                    Text("Posture")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: {} ) {
                        Text(posInput)
                    }
                }
                
            }
            
            Spacer()
        }
        .textFieldAlert(isShowing: $showingGoals, text: $goalInput, title: Text("What are your goals?"))
        .textFieldAlert(isShowing: $showingExp, text: $motInput, title: Text("What is your expectation"))
    }
}

struct PrepView_Previews: PreviewProvider {
    static var previews: some View {
        PrepView()
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
