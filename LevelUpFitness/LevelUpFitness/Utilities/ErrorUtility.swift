//
//  ErrorUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/10/24.
//

import Foundation

class ErrorUtility {
    static func isSpecificError(_ error: Error, codes: [Int], domain: String) -> Bool {
        let nsError = error as NSError
        return nsError.domain == domain && codes.contains(nsError.code)
    }
}
