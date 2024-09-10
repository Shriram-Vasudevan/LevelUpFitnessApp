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
    
    func toDoListInit() async {
        await initializeToDoList()
        checkIfStepGoalMet()
    }
    
    func initializeToDoList() async {
        do {
            if toDoList.count == 0 {
                print("to do list \(toDoList)")
                if !LocalStorageUtility.fileModifiedToday(at: "todoList.json") {
                    LocalStorageUtility.clearFile(at: "todoList.json")
                    
                    let jsonEncoder = JSONEncoder()
                    
                    let programTask = ToDoListTask(id: UUID().uuidString, description: "Complete Your Program for Today", completed: false, currentValue: 0.0, taskType: .program)
                    DispatchQueue.main.async {
                        self.toDoList.append(programTask)
                    }
                    
                    if let programTaskData = try? jsonEncoder.encode(programTask) {
                        LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "todoList.json", data: programTaskData)
                    }
                    
                    HealthManager.shared.fetchAverageSteps(forLastNDays: 7) { averageSteps in
                        var goalSteps = averageSteps + 500
                        goalSteps = round((goalSteps + 50) / 100) * 100
                        print("step goal \(goalSteps)")
                        let taskDescription = "Reach \(Int(goalSteps)) steps"
                        let stepTask = ToDoListTask(id: UUID().uuidString, description: taskDescription, completed: false, currentValue: 0.0, completionValue: goalSteps, taskType: .steps)
                        
                        DispatchQueue.main.async {
                            self.toDoList.append(stepTask)
                        }
                        
                        if let stepTaskData = try? jsonEncoder.encode(stepTask) {
                            LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "todoList.json", data: stepTaskData)
                        }
                    }
                    
                    let weightTask = ToDoListTask(id: UUID().uuidString, description: "Add your Weight", completed: false, currentValue: 0.0, taskType: .weight)
                    DispatchQueue.main.async {
                        self.toDoList.append(weightTask)
                    }
                    
                    if let weightTaskData = try? jsonEncoder.encode(weightTask) {
                        LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "todoList.json", data: weightTaskData)
                    }
                    
                    let xpTask = ToDoListTask(id: UUID().uuidString, description: "Gain 100 XP", completed: false, currentValue: 0, completionValue: 100, taskType: .xp)
                    DispatchQueue.main.async {
                        self.toDoList.append(xpTask)
                    }
                    
                    if let xpTaskData = try? jsonEncoder.encode(xpTask) {
                        LocalStorageUtility.appendDataToDocumentsDirectoryFile(at: "todoList.json", data: xpTaskData)
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
            }
        } catch {
            print("initialize error \(error)")
        }
    }
    
    func checkIfStepGoalMet() {
        if let stepTaskIndex = toDoList.firstIndex(where: { toDoListTask in
            toDoListTask.taskType == .steps
        }) {
            if toDoList[stepTaskIndex].completed == false {
                guard let steps = HealthManager.shared.todaysSteps?.count, let stepGoal = toDoList[stepTaskIndex].completionValue else { return }
                
                if Double(steps) >= stepGoal {
                    toDoList[stepTaskIndex].completed = true
                    let taskID = toDoList[stepTaskIndex].id
                    LocalStorageUtility.updateTaskCompletionInFile(taskID: taskID, completed: true)
                    
                    Task {
                        await LevelChangeManager.shared.createNewLevelChange(property: "MetStepsGoal", contribution: 5)
                        await XPManager.shared.addXPToDB()
                    }
                }
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
    
    func weightAdded() {
        print("weight added")
        if let weightTaskIndex = toDoList.firstIndex(where: { toDoListTask in
            toDoListTask.taskType == .weight
        }) {
            toDoList[weightTaskIndex].completed = true
            let taskID = toDoList[weightTaskIndex].id
            LocalStorageUtility.updateTaskCompletionInFile(taskID: taskID, completed: true)
            
            Task {
                await LevelChangeManager.shared.createNewLevelChange(property: "AddedWeight", contribution: 3)
                await XPManager.shared.addXPToDB()
            }
        }
    }
    
    func xpAdded(xp: Int) {
        if let xpTaskIndex = toDoList.firstIndex(where: { toDoListTask in
            toDoListTask.taskType == .xp
        }) {
            guard let completionValue = toDoList[xpTaskIndex].completionValue else { return }
            toDoList[xpTaskIndex].currentValue += Double(xp)
            
            if toDoList[xpTaskIndex].currentValue >= completionValue {
                toDoList[xpTaskIndex].completed = true
                let taskID = toDoList[xpTaskIndex].id
                LocalStorageUtility.updateTaskCompletionInFile(taskID: taskID, completed: true)
                
                Task {
                    await LevelChangeManager.shared.createNewLevelChange(property: "MetXPGoal", contribution: 7)
                    await XPManager.shared.addXPToDB()
                }
            }
            
        }
    }
}
