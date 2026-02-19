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
        if let todaysProgram = ProgramManager.shared.selectedProgram?.program.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
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
            
            if let selectedProgramIndex = ProgramManager.shared.userProgramData.firstIndex(where: { $0.program.programName == ProgramManager.shared.selectedProgram?.program.programName }) {
                if let programDayIndex = ProgramManager.shared.selectedProgram?.program.program.firstIndex(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                    
                    ProgramManager.shared.selectedProgram?.program.program[programDayIndex].exercises[currentExerciseIndex].completed = true
                    ProgramManager.shared.selectedProgram?.program.program[programDayIndex].exercises[currentExerciseIndex].data = currentExerciseData
                    
                    let xpAdditionType = getExerciseTypeEnum(exerciseType: ProgramManager.shared.selectedProgram?.program.program[programDayIndex].exercises[currentExerciseIndex].area ?? "")
                    XPManager.shared.addXP(increment: 2, type: xpAdditionType)

                    if let selectedProgram = ProgramManager.shared.selectedProgram {
                        ProgramManager.shared.userProgramData[selectedProgramIndex].program = selectedProgram.program
                    }
                    
                    DispatchQueue.main.async {
                        ProgramManager.shared.objectWillChange.send()
                    }
                }
            }

            addCurrentExerciseToGymSession()
            
            currentExerciseIndex += 1
            initializeExerciseData()
            objectWillChange.send()
        } else {
            if let programArray = ProgramManager.shared.selectedProgram?.program.program,
               let programIndex = programArray.firstIndex(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                var todaysProgram = programArray[programIndex]
                todaysProgram.exercises[currentExerciseIndex].completed = true
                todaysProgram.exercises[currentExerciseIndex].data = currentExerciseData
                
                todaysProgram.completed = true
                
                let xpAdditionType = getExerciseTypeEnum(exerciseType: todaysProgram.exercises[currentExerciseIndex].area)
                XPManager.shared.addXP(increment: 3, type: xpAdditionType)
                
                ProgramManager.shared.selectedProgram?.program.program[programIndex] = todaysProgram
                
            }
            objectWillChange.send()
            
            print("Workout completed")
            
            saveProgramStatus()
            
            Task {
                await LevelChangeManager.shared.createNewLevelChange(property: "Program", contribution: 5)
            }
            
            ToDoListManager.shared.programCompleted()
            
            programCompletedForDay = true
        }
    }
    
    func addCurrentExerciseToGymSession() {
           guard let currentSession = GymManager.shared.currentSession,
                 let selectedProgram = ProgramManager.shared.selectedProgram else {
               return
           }

           let currentExercise = currentExercises[currentExerciseIndex]

           let exerciseRecord = ExerciseRecord(
               exerciseInfo: .programExercise(currentExercise),
               exerciseData: currentExerciseData
           )

           GymManager.shared.currentSession?.addProgramExercise(
                programName: selectedProgram.program.programName,
               exerciseRecord: exerciseRecord
           )
           GymManager.shared.saveGymSession(currentSession)
       }
    
    func saveProgramStatus() {
        Task {
            if let todaysProgram = ProgramManager.shared.selectedProgram?.program.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                print("uploading new status")
                await programManager.uploadNewProgramStatus(completion: { success in
                    if success {
                    } else {
                        
                    }
                })
            }
        }
    }
    
    func getExerciseTypeEnum(exerciseType: String) -> XPAdditionType {
        switch exerciseType {
        case "Lower Body Compound":
            return .lowerBodyCompound
        default:
            return .lowerBodyCompound
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
