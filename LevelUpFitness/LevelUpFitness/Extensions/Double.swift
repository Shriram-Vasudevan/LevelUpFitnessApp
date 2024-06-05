//
//  Double.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/4/24.
//

import Foundation

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
