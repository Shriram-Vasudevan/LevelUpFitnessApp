//
//  ExerciseLibraryExercise.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/14/24.
//

import Foundation

struct ExerciseLibraryExercise: Codable, Hashable, Equatable {
    var id: String
    var name: String
    var exerciseType: String
    var progression: [Progression]
    var isWeight: Bool
    
    enum CodingKeys: String, CodingKey {
        case id = "ID"
        case name = "Name"
        case exerciseType = "ExerciseType"
        case progression = "Progression"
        case isWeight = "IsWeight"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        
        name = try container.decode(String.self, forKey: .name)
        
        exerciseType = try container.decode(String.self, forKey: .exerciseType)
        
        isWeight = try container.decode(Bool.self, forKey: .isWeight)
        
        let progressionDict = try container.decode([String: Progression].self, forKey: .progression)
        //print("Decoded Progression Dictionary \(progressionDict)")

        progression = Array(progressionDict.values)
        //print("Array \(progression)")
    }
    
    static func preview() -> ExerciseLibraryExercise? {
        let jsonString = """
        [{
            "ID": "65ff0e13-39b9-4579-9ca5-8ebc89d3db1c",
            "Name": "Squat",
            "ExerciseType": "Lower Body Compound",
            "Progression": {
                "Bodyweight Squat": {
                    "Name": "Bodyweight Squat",
                    "Description": "Stand with feet shoulder-width apart, toes slightly pointed out. Keep your chest up and core engaged. Lower yourself by bending your knees and hips as if sitting back into a chair until your thighs are parallel to the ground. Return to the starting position.",
                    "Level": 1,
                    "CDNURL": "https://d18etpeujljjnv.cloudfront.net/SampleExercise.mp4",
                    "ExerciseType": "Lower Body Compound"
                },
                "Pause Squat": {
                    "Name": "Pause Squat",
                    "Description": "Perform a standard bodyweight squat, but pause for 2-3 seconds at the bottom of the movement before standing back up. This builds strength and control in the bottom position.",
                    "Level": 2,
                    "CDNURL": "https://d18etpeujljjnv.cloudfront.net/SampleExercise.mp4",
                    "ExerciseType": "Lower Body Compound"
                },
                "Reach Squat": {
                    "Name": "Reach Squat",
                    "Description": "Perform a bodyweight squat while extending your arms straight in front of you or overhead as you lower down. This adds a challenge to your balance and engages your shoulders and upper back.",
                    "Level": 3,
                    "CDNURL": "https://d18etpeujljjnv.cloudfront.net/SampleExercise.mp4",
                    "ExerciseType": "Lower Body Compound"
                }
            }
        }]
        """
        
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            let decoder = JSONDecoder()
            let exercises = try decoder.decode([ExerciseLibraryExercise].self, from: jsonData)
            return exercises.first
        } catch {
            print("Failed to decode ExerciseLibraryExercise: \(error)")
            return nil
        }
    }
}

struct Progression: Codable, Hashable, Equatable {
    var name: String
    var description: String
    var level: Int
    var cdnURL: String
    var exerciseType: String
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case description = "Description"
        case level = "Level"
        case cdnURL = "CDNURL"
        case exerciseType = "ExerciseType"
    }
    
    static func preview() -> Progression? {
        let jsonString = """
        {
            "Name": "Strength Training",
            "Description": "A progression focused on building muscle strength.",
            "Level": 3,
            "CDNURL": "https://example.com/strength_training.mp4",
            "ExerciseType": "Strength"
        }
        """

        let jsonData = jsonString.data(using: .utf8)!

        do {
            let decoder = JSONDecoder()
            let progression = try decoder.decode(Progression.self, from: jsonData)
            return progression
        }
        catch {
            return nil
        }
    }
}

