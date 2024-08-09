//
//  DateUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

class DateUtility {
    static func getPreviousMondayDate() -> String? {
        let calendar = Calendar.current
        
        let weekdayComponent = calendar.component(.weekday, from: Date())
        let dayToSubtract = (weekdayComponent == 1 ? 6 : weekdayComponent - 2)
        
        if let previousMonday = calendar.date(byAdding: .day, value: -dayToSubtract, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            return dateFormatter.string(from: previousMonday)
        }
        else {
            return nil
        }
    }
}
