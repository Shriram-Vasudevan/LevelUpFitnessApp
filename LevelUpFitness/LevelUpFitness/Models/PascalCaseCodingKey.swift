//
//  PascalCaseCodingKey.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import Foundation

struct PascalCaseKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(stringValue: String) {
        self.stringValue = stringValue.prefix(1).lowercased() + stringValue.dropFirst()
        intValue = nil
    }

    init(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}
