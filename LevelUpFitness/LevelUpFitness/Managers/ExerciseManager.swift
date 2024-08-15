//
//  ExerciseManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/12/24.
//

import Foundation
import Amplify

@MainActor
class ExerciseManager: ObservableObject {
    static let shared = ExerciseManager()
    
    @Published var exercises: [ExerciseLibraryExercise] = []
    
    @Published var recommendedExercise: ExerciseLibraryExercise?
    init() {
        Task {
            await getExercises()
            
            if let recommendedExercise = getRecommendedExercise() {
                self.recommendedExercise = recommendedExercise
            }
        }
    }
    
    func getExercises() async {
        do  {
            print("here")
            self.exercises = try await ProgramDynamoDBUtility.getExercises()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getRecommendedExercise() -> ExerciseLibraryExercise? {
        if exercises.count > 0 {
            if let recommendedExercise = exercises.randomElement() {
                return recommendedExercise
            }
        } else {
            return nil
        }
        
        return nil
    }
    

}
