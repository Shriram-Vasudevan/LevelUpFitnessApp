//
//  ToDoListManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/22/24.
//

import Foundation

class ToDoListManager: ObservableObject {
    @Published var toDoList: [String] = []
}
