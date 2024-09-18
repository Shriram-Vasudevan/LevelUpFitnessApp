//
//  CustomWorkoutManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/16/24.
//

import Foundation

class CustomWorkoutManager: ObservableObject {
    static let shared = CustomWorkoutManager()
    
    @Published var customWorkouts: [CustomWorkout] = []
    
    init() {
        getAllCustomWorkouts()
    }
    
    func addCustomWorkout(workout: CustomWorkout) {
        guard let customWorkoutsDirectory = getCustomWorkoutsDirectory() else { return }
        
        if !FileManager.default.fileExists(atPath: customWorkoutsDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: customWorkoutsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating CustomWorkouts directory: \(error.localizedDescription)")
                return
            }
        }

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(workout)
            
            let workoutFileURL = customWorkoutsDirectory.appendingPathComponent("\(workout.name).json")
            
            try data.write(to: workoutFileURL)
            print("Workout saved at: \(workoutFileURL.path)")
            self.customWorkouts.append(workout)
            
        } catch {
            print("Error saving custom workout: \(error.localizedDescription)")
        }
    }
    
    func getAllCustomWorkouts() {
        customWorkouts.removeAll()
                guard let customWorkoutsDirectory = getCustomWorkoutsDirectory() else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: customWorkoutsDirectory, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "json" {
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    let workout = try decoder.decode(CustomWorkout.self, from: data)
                    customWorkouts.append(workout)
                }
            }
            
        } catch {
            print("Error loading custom workouts: \(error.localizedDescription)")
        }
    }
    
    private func getCustomWorkoutsDirectory() -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]

        return documentsDirectory.appendingPathComponent("CustomWorkouts")
    }
}
