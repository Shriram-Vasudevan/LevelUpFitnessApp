//
//  KeyboardResponder.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import Foundation
import SwiftUI

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            withAnimation {
                keyboardHeight = keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        withAnimation {
            keyboardHeight = 0
        }
    }
}
