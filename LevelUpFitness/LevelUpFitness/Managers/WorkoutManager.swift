//
//  WorkoutManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/5/24.
//

import Foundation
import SwiftUI

@MainActor
class WorkoutManager: ObservableObject {
    @Published var currentExercises: [ProgramExercise] = []
    @Published var currentExerciseData: ExerciseData = ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 0, time: 0.0, rest: 0.0)])
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0

    @Published var programCompletedForDay: Bool = false
    
    var programManager: ProgramManager
    var xpManager: XPManager
    
    init(programManager: ProgramManager, xpManager: XPManager) {
        self.programManager = programManager
        self.xpManager = xpManager
    }
   
    func initializeExerciseData() {
        if let todaysProgram = ProgramManager.shared.selectedProgram?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
            self.currentExercises = todaysProgram.exercises
            
            if currentExerciseIndex == 0 {
                if let (index, _) = todaysProgram.exercises.enumerated().first(where: { $0.element.completed == false }) {
                    self.currentExerciseIndex = index
                } else {
                    print("All exercises completed")
                    return
                }
            }
            
            var exerciseDataSets: [ExerciseDataSet] = []
            
            for _ in 0..<currentExercises[currentExerciseIndex].sets {
                        let set = ExerciseDataSet(weight: 0, reps: 0, time: 0.0, rest: 0.0)
                        exerciseDataSets.append(set)
                    }

            currentExerciseData = ExerciseData(sets: exerciseDataSets)
            currentSetIndex = 0
            print(currentExerciseData.sets)
            
            print("Initialized exercise data for exercise \(currentExerciseIndex)")
        } else {
            print("No program found for today")
        }
    }
    
    func moveToNextSet() {
        if currentSetIndex < currentExerciseData.sets.count - 1 {
            currentSetIndex += 1
            objectWillChange.send()
        }
        else {
            moveToNextExercise()
        }
    }
    
    func moveToNextExercise() {
        if currentExerciseIndex < currentExercises.count - 1 {
            print("Moving to next exercise")
            currentSetIndex = 0
            
            if let programArray = ProgramManager.shared.selectedProgram?.program,
               let programIndex = programArray.firstIndex(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                var todaysProgram = programArray[programIndex]
                todaysProgram.exercises[currentExerciseIndex].completed = true
                todaysProgram.exercises[currentExerciseIndex].data = currentExerciseData
                
                print(todaysProgram.exercises[currentExerciseIndex].name)
                print(todaysProgram.exercises[currentExerciseIndex].completed)
                
                ProgramManager.shared.selectedProgram?.program[programIndex] = todaysProgram
                
                print(ProgramManager.shared.selectedProgram?.program)
            }

            currentExerciseIndex += 1
            initializeExerciseData()
            objectWillChange.send()
        } else {
            if let programArray = ProgramManager.shared.selectedProgram?.program,
               let programIndex = programArray.firstIndex(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                var todaysProgram = programArray[programIndex]
                todaysProgram.exercises[currentExerciseIndex].completed = true
                todaysProgram.exercises[currentExerciseIndex].data = currentExerciseData
                
                print(todaysProgram.exercises[currentExerciseIndex].name)
                print(todaysProgram.exercises[currentExerciseIndex].completed)
                
                todaysProgram.completed = true
                
                ProgramManager.shared.selectedProgram?.program[programIndex] = todaysProgram
                
                print(ProgramManager.shared.selectedProgram?.program)
            }
            objectWillChange.send()
            
            print("Workout completed")
            
            saveProgramStatus()
            
            Task {
                await LevelChangeManager.shared.createNewLevelChange(property: "Program", contribution: 5)
                await XPManager.shared.addXPToDB()
            }
            
            ToDoListManager.shared.programCompleted()
            
            programCompletedForDay = true
        }
    }
    
    func saveProgramStatus() {
        Task {
            if let todaysProgram = ProgramManager.shared.selectedProgram?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                print("uploading new status")
                await programManager.uploadNewProgramStatus(programName: ProgramManager.shared.selectedProgram?.programName ?? "", completion: { success in
                    if success {
                    } else {
                        
                    }
                })
            }
        }
    }
  
//    func resetFields() {
//        for i in 0..<currentExerciseData.count {
//            currentExerciseData[i].clear = true
//        }
//    }
//    
//    func getAllExerciseDatas() -> [ExerciseData] {
//        return currentExerciseData.map { ExerciseData(from: $0) }
//    }
//    
    func isWorkoutComplete() -> Bool {
        return currentExerciseIndex >= currentExercises.count
    }
    
    func hasExercisesForToday() -> Bool {
        return !currentExercises.isEmpty
    }
}
