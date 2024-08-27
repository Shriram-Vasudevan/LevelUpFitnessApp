//
//  ProgramDynamoDBUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation
import Amplify

class ProgramDynamoDBUtility {
    static func getUserProgramDBRepresentation() async -> (String, String)? {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getUserProgramInfo", queryParameters: ["UserID" : userID])
            let response = try await Amplify.API.get(request: request)
            
            let jsonString = String(data: response, encoding: .utf8)
          //  print("program db representation \(jsonString)")
            
            let jsonDecoder = JSONDecoder()
            let programDBRepresentation = try jsonDecoder.decode(ProgramDBRepresentation.self, from: response)
            
            return (programDBRepresentation.program, programDBRepresentation.startDate)
        } catch {
            print("The db program error \(error)")
            return nil
        }
    }
    
    static func addProgramToDB(programName: String, startDate: String) async throws {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/addUserProgram", queryParameters: ["UserID" : userID, "Program" : programName, "StartDate": startDate])
            let response = try await Amplify.API.put(request: request)
        } catch {
            print(error)
            throw APIError.failed
        }
    }
    
    static func getExercises() async throws -> [ExerciseLibraryExercise] {
        do {
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/getExercises")
            let response = try await Amplify.API.get(request: request)
            
            //print("getExercises: \(String(data: response, encoding: .utf8))")
            let decoder = JSONDecoder()
            
            let exercises = try decoder.decode([ExerciseLibraryExercise].self, from: response)
            
            return exercises
        } catch {
            print("getExercises \(error)")
            throw APIError.failed
        }
    }
    
    static func leaveProgram(programName: String) async {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
//            guard let program = self.program else { return }
            
            let request = RESTRequest(apiName: "LevelUpFitnessDynamoAccessAPI", path: "/leaveProgram", queryParameters: ["UserID" : "\(userID)", "ProgramName" : "\(programName)"])
            
            let response = try await Amplify.API.delete(request: request)
            
            print(String(data: response, encoding: .utf8))

//            if self.standardProgramNames == nil {
//                await getStandardProgramNames()
//            }
        } catch {
            print(error)
        }
    }
}
