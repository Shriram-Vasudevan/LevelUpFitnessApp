//
//  ToDoListManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/22/24.
//

import Foundation

@MainActor
class ToDoListManager: ObservableObject {
    static let shared = ToDoListManager()
    
    @Published var toDoList: [ToDoListTask] = []
    
    init() {
        Task {
            await initializeToDoList()
            checkIfStepGoalMet()
        }
    }
    
    func initializeToDoList() async {
        do {
            if !LocalStorageUtility.fileModifiedToday(at: "todoList.json") {
                LocalStorageUtility.clearFile(at: "todoList.json")
                
                let jsonEncoder = JSONEncoder()
                
                let programTask = ToDoListTask(id: UUID().uuidString, description: "Complete Your Program for Today", completed: false, taskType: .program)
                DispatchQueue.main.async {
                    self.toDoList.append(programTask)
                }
                
                if let programTaskData = try? jsonEncoder.encode(programTask) {
                    LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "todoList.json", data: programTaskData)
                }
                
                HealthManager.shared.fetchAverageSteps(forLastNDays: 7) { averageSteps in
                    let goalSteps = averageSteps + 500
                    let taskDescription = "Reach \(Int(goalSteps)) steps today"
                    let stepTask = ToDoListTask(id: UUID().uuidString, description: taskDescription, completed: false, completionValue: goalSteps, taskType: .steps)
                    
                    DispatchQueue.main.async {
                        self.toDoList.append(stepTask)
                    }
                    
                    if let stepTaskData = try? jsonEncoder.encode(stepTask) {
                        LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "todoList.json", data: stepTaskData)
                    }
                }
                
                print("to do list \(toDoList)")
            }
            else {
                guard let fileContent = LocalStorageUtility.readDocumentsDirectoryJSONStringFile(at: "todoList.json") else { return }

                let toDoListStrings = fileContent.components(separatedBy: .newlines).filter { !$0.isEmpty }
                
                let jsonDecoder = JSONDecoder()
                
                for toDoListString in toDoListStrings {
                    if let toDoListData = toDoListString.data(using: .utf8) {
                        do {
                            let toDoListTask = try jsonDecoder.decode(ToDoListTask.self, from: toDoListData)
                            toDoList.append(toDoListTask)
                        } catch {
                            print("Failed to decode line: \(toDoListString), error: \(error)")
                            continue
                        }
                    }
                }
            }
        } catch {
            print("initialize error \(error)")
        }
    }
    
    func checkIfStepGoalMet() {
        if let stepTaskIndex = toDoList.firstIndex(where: { toDoListTask in
            toDoListTask.taskType == .steps
        }) {
            guard let steps = HealthManager.shared.todaysSteps?.count, let stepGoal = toDoList[stepTaskIndex].completionValue else { return }
            
            if Double(steps) >= stepGoal {
                toDoList[stepTaskIndex].completed = true
                let taskID = toDoList[stepTaskIndex].id
                LocalStorageUtility.updateTaskCompletionInFile(taskID: taskID, completed: true)
            }
        }
    }
    
    func programCompleted() {
        if let programTaskIndex = toDoList.firstIndex(where: { toDoListTask in
            toDoListTask.taskType == .program
        }) {
            toDoList[programTaskIndex].completed = true
            let taskID = toDoList[programTaskIndex].id
            LocalStorageUtility.updateTaskCompletionInFile(taskID: taskID, completed: true)
            
        }
    }
}
