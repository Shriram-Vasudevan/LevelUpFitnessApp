//
//  WorkoutManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/5/24.
//

import Foundation
import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var currentExercises: [Exercise] = []
    @Published var currentExerciseData: ExerciseData = ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 0, time: 0.0, rest: 0.0)])
    @Published var currentExerciseIndex: Int = 0
    @Published var currentSetIndex: Int = 0
    @Published var onLastSet: Bool = false

    var storageManager: StorageManager
    
    init(storageManager: StorageManager) {
        self.storageManager = storageManager
    }
   
    func initializeExerciseData() {
        if let todaysProgram = storageManager.program?.program.first(where: { $0.day == getCurrentWeekday() }) {
            self.currentExercises = todaysProgram.exercises
            
            if let (index, _) = todaysProgram.exercises.enumerated().first(where: { $0.element.completed == false }) {
                self.currentExerciseIndex = index
            } else {
                print("All exercises completed")
                return
            }
            
            var exerciseDataSets: [ExerciseDataSet] = []
            
            for _ in 0..<currentExercises[currentExerciseIndex].sets {
                let set = ExerciseDataSet(weight: 0, reps: 0, time: 0.0, rest: 0.0)
                exerciseDataSets.append(set)
            }
            
            currentExerciseData = ExerciseData(sets: exerciseDataSets)
            
            print("Initialized exercise data for exercise \(currentExerciseIndex)")
        } else {
            print("No program found for today")
        }
    }
//    
//    func addExerciseData(index: Int) {
//        if index + 1 < currentExerciseData.count {
//            currentExerciseData[index + 1].isAvailable = true
//            
////            if index + 1 == currentExerciseData.count - 1 {
////                currentExerciseData[index + 1].isLast = true
////            }
//        }
//        else {
//            withAnimation {
//
//                currentExercises[currentExerciseIndex].completed = true
//                
//                if let dayIndex = storageManager.program?.program.firstIndex(where: { $0.day == getCurrentWeekday() }) {
//                    storageManager.program?.program[dayIndex].exercises = currentExercises
//                    
//                    storageManager.program?.program[dayIndex].exercises[currentExerciseIndex].data = getAllExerciseDatas()
//
//                }
//                
//                resetFields()
//            }
//        }
//    }
//    
//
    func moveToNextSet() {
        if currentSetIndex < currentExerciseData.sets.count - 1 {
            self.onLastSet = currentSetIndex + 1 == currentExerciseData.sets.count - 1
            currentSetIndex += 1
        }
    }
    
    func moveToNextExercise() {
        if currentExerciseIndex < currentExercises.count - 1 {
            print("Moving to next exercise")
//            addExerciseData(index: currentExerciseIndex)
            currentSetIndex = 0
            currentExerciseIndex += 1
            initializeExerciseData()
        } else {
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
