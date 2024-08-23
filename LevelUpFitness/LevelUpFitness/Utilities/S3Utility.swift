//
//  S3Utility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/23/24.
//

import Foundation
import Amplify

class S3Utility {
    static func getUserProgramFilePaths(programS3Representation: String) async -> [String]? {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessS3AccessAPI", path: "/getUserProgramFiles", queryParameters: ["UserID" : userID, "FolderName": programS3Representation])
            
            let response = try await Amplify.API.get(request: request)
            let responseString = String(data: response, encoding: .utf8)
            
            print("the response \(responseString)")
            let responseArray = try JSONDecoder().decode([String].self, from: response)
            
            let responseValuesCleaned = responseArray.map({$0.trimmingCharacters(in: CharacterSet(charactersIn: "[]\""))})
            
            return responseValuesCleaned
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    static func downloadPastPrograms(programS3Representation: String, programNames: String) async -> [Program]? {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            var programs: [Program] = []
            
            for programName in programNames {
                let downloadTask = Amplify.Storage.downloadData(key: "UserPrograms/\(userID)/\(programS3Representation)/\(programName).json")
                
                let data = try await downloadTask.value
                
                let decoder = JSONDecoder()
                var decodedData = try decoder.decode(Program.self, from: data)
            }
            
            return programs
        } catch {
            print(error)
            return nil
        }
    }
}
