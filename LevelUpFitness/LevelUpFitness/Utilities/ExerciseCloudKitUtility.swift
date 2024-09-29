//
//  ExerciseCloudKitUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/29/24.
//

import Foundation

import Foundation
import CloudKit

class ExerciseCloudKitUtility {
    static let customContainer = CKContainer(identifier: "iCloud.LevelUpFitnessCloudKitStorage")
    
    static func fetchExercisesJSONFromCloudKit() async throws -> [ExerciseLibraryExercise] {
        let predicate = NSPredicate(value: true) 
        let query = CKQuery(recordType: "ExerciseLibraryExercise", predicate: predicate)
        
        let (matchResults, _) = try await customContainer.publicCloudDatabase.records(matching: query)
        

        for matchResult in matchResults {
            switch matchResult.1 {
            case .success(let record):
                if let jsonFile = record["jsonData"] as? CKAsset,
                   let fileURL = jsonFile.fileURL {
                    return try decodeExercises(from: fileURL)
                }
            case .failure(let error):
                print("Error fetching record: \(error.localizedDescription)")
            }
        }

        return []
    }

    static private func decodeExercises(from fileURL: URL) throws -> [ExerciseLibraryExercise] {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let exercises = try decoder.decode([ExerciseLibraryExercise].self, from: data)
        return exercises
    }
}
