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
    @Published var onLastSet: Bool = false

    var programManager: ProgramManager
    var xpManager: XPManager
    
    init(programManager: ProgramManager, xpManager: XPManager) {
        self.programManager = programManager
        self.xpManager = xpManager
    }
   
    func initializeExerciseData() {
        if let todaysProgram = programManager.program?.program.first(where: { $0.day == getCurrentWeekday() }) {
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
            print(currentExerciseData.sets)
            
            print("Initialized exercise data for exercise \(currentExerciseIndex)")
        } else {
            print("No program found for today")
        }
    }
    
    func moveToNextSet() {
        if currentSetIndex < currentExerciseData.sets.count - 1 {
            currentSetIndex += 1
            onLastSet = currentSetIndex == currentExerciseData.sets.count - 1
            objectWillChange.send()
        }
    }
    
    func moveToNextExercise() {
        if currentExerciseIndex < currentExercises.count - 1 {
            print("Moving to next exercise")
            currentSetIndex = 0
            onLastSet = false
            
            if let programArray = programManager.program?.program,
               let programIndex = programArray.firstIndex(where: { $0.day == getCurrentWeekday() }) {
                var todaysProgram = programArray[programIndex]
                todaysProgram.exercises[currentExerciseIndex].completed = true
                todaysProgram.exercises[currentExerciseIndex].data = currentExerciseData
                
                print(todaysProgram.exercises[currentExerciseIndex].name)
                print(todaysProgram.exercises[currentExerciseIndex].completed)
                
                programManager.program?.program[programIndex] = todaysProgram
                
                print(programManager.program?.program)
            }

            currentExerciseIndex += 1
            initializeExerciseData()
            objectWillChange.send()
        } else {
            if let programArray = programManager.program?.program,
               let programIndex = programArray.firstIndex(where: { $0.day == getCurrentWeekday() }) {
                var todaysProgram = programArray[programIndex]
                todaysProgram.exercises[currentExerciseIndex].completed = true
                todaysProgram.exercises[currentExerciseIndex].data = currentExerciseData
                
                print(todaysProgram.exercises[currentExerciseIndex].name)
                print(todaysProgram.exercises[currentExerciseIndex].completed)
                
                todaysProgram.completed = true
                
                programManager.program?.program[programIndex] = todaysProgram
                
                print(programManager.program?.program)
            }
            objectWillChange.send()
            
            print("Workout completed")
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
    
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}
