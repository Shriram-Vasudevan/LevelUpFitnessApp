//
//  ViewModifiers.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/12/24.
//

import Foundation
import SwiftUI
struct DoneButtonToolbar: ViewModifier {
    @Binding var isFirstResponder: Bool
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        self.isFirstResponder = false
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
    }
}
