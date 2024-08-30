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
    
    @Published var recommendedExercise: Progression?
    @Published var recommendedExerciseType: String?
    
    func exerciseManagerInit() async {
        await getExercises()
        
        if let recommendedExercise = getRecommendedProgression() {
            self.recommendedExercise = recommendedExercise
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
    
    func getRecommendedProgression() -> Progression? {
        let allProgressions = self.exercises.flatMap { $0.progression }
        
        guard allProgressions.count > 0 else {
            return nil
        }
        
        return allProgressions.randomElement()
    }
    

}
