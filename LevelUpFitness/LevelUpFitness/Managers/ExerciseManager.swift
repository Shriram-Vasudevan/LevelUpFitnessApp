//
//  ExerciseManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/12/24.
//

import Foundation

@MainActor
class ExerciseManager: ObservableObject {
    static let shared = ExerciseManager()
    
    @Published var exercises: [ExerciseLibraryExercise] = []
    
    @Published var recommendedExercise: Progression?
    @Published var recommendedExerciseType: String?
    
    func exerciseManagerInit() async {
        await getExercisesFromCloudKit()
        
        if let recommendedExercise = getRecommendedProgression() {
            self.recommendedExercise = recommendedExercise
        }
    }
    
    func getExercisesFromCloudKit() async {
        do {
            print("Fetching exercises JSON from CloudKit...")
            self.exercises = try await ExerciseCloudKitUtility.fetchExercisesJSONFromCloudKit()
            print("Exercises successfully fetched and decoded.")
        } catch {
            print("Failed to fetch exercises: \(error.localizedDescription)")
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
