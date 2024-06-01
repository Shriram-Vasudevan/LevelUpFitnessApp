//
//  ProgramWorkoutManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/29/24.
//

import Foundation
import Amplify
import AWSAPIPlugin

import AWSCognitoAuthPlugin

class ProgramWorkoutManager {
    
    func uploadNewProgramStatus(program: Program) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(program)
            let jsonString = String(data: jsonData, encoding: .utf8)
            print(jsonString)
            
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let fileURL = temporaryDirectory.appendingPathComponent("\(userID).json")
            
            try jsonData.write(to: fileURL)
            
            Amplify.Storage.uploadFile(key: "UserPrograms/\(userID).json", local: fileURL)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}
