//
//  ToDoListTask.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/27/24.
//

import Foundation

struct ToDoListTask: Identifiable, Codable {
    var id: String
    var description: String
    var completed: Bool
    var currentValue: Double
    var completionValue: Double?
    var taskType: ToDoListTaskType
}

enum ToDoListTaskType: Codable {
    case program, steps, weight, xp
}
