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
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}
