//
//  DateUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

class DateUtility {
    static func createDateDurationISO(duration: Int) -> (String, String)? {
        let currentDate = Date()
        
        guard let modifiedDate = Calendar.current.date(byAdding: .day, value: duration, to: currentDate) else { return nil }
        
        return (currentDate.ISO8601Format(), modifiedDate.ISO8601Format())
    }
    
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
