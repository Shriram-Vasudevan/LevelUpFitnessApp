//
//  SizePreferanceKey.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/1/24.
//

import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
