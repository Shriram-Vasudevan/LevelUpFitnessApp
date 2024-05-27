//
//  Workout.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import Foundation

struct Workout: Identifiable, Codable {
    var id: String
    var title: String
    var date: String
    var trainer: String
    var location: String
    var isPaid: Bool
}
