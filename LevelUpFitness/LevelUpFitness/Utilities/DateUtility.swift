//
//  DateUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/9/24.
//

import Foundation

class DateUtility {
    static func weekDurationExceeded(startDate: String, weeks: Int) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        guard let firstDate = dateFormatter.date(from: startDate) else { return false }
        
        let secondDate = Date()
        
        let calendar = Calendar.current
        guard let weeksDifference = calendar.dateComponents([.weekOfYear], from: firstDate, to: secondDate).weekOfYear else {
            return false
        }
        
        return weeksDifference > weeks
    }

    
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
    
    static func getLastDateForWeekday(weekday: String) -> String? {
        let weekdayMap = [
            "sunday": 1,
            "monday": 2,
            "tuesday": 3,
            "wednesday": 4,
            "thursday": 5,
            "friday": 6,
            "saturday": 7
        ]
        
        let calendar = Calendar.current
        
        guard let targetWeekday = weekdayMap[weekday.lowercased()] else {
            return nil
        }
        
        let currentWeekdayComponent = calendar.component(.weekday, from: Date())
        
        var dayToSubtract = currentWeekdayComponent - targetWeekday
        if dayToSubtract < 0 {
            dayToSubtract += 7
        }
        
        if let lastWeekdayDate = calendar.date(byAdding: .day, value: -dayToSubtract, to: Date()) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            return dateFormatter.string(from: lastWeekdayDate)
        }
        
        return nil
    }
    
    static func getCurrentDate() -> String {
        let currentDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        return dateFormatter.string(from: currentDate)
    }

    static func getWeekdayFromDate(date: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        guard let date = dateFormatter.date(from: date) else { return nil }
        
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
    
    static func getDateNWeeksAfterDate(dateString: String, weeks: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"

        guard let date = dateFormatter.date(from: dateString) else {
            return nil
        }

        let weeksAfter = Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: date)

        guard let finalDate = weeksAfter else {
            return nil
        }

        return dateFormatter.string(from: finalDate)
    }
    
    static func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}
