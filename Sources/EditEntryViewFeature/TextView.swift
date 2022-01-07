//  TextView.swift
//  Strong Karma
//
//  Created by Justin Smith Nussli on 10/30/19.
//  Copyright © 2019 Justin Smith. All rights reserved.
//

import SwiftUI
import UIKit


public struct TextView: UIViewRepresentable {
    @Binding var text: String
  var onCommit: () -> Void = {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UITextView {

        let myTextView = UITextView()
        myTextView.delegate = context.coordinator

        myTextView.font = UIFont(name: "HelveticaNeue", size: 15)
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
     
        //myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)

        return myTextView
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }

    public class Coordinator : NSObject, UITextViewDelegate {

        var parent: TextView

        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }

        public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }

        public func textViewDidChange(_ textView: UITextView) {
            self.parent.text = textView.text
        }
      
        public func textViewDidEndEditing(_ textView: UITextView) {
        self.parent.onCommit()
      }
    }
}
