//
//  StringUtility.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/23/24.
//

import Foundation

class StringUtility {
    static func formatS3ProgramRepresentation(_ input: String) -> String? {
        
        print("the cleaned input \(input)")
        guard let openParenIndex = input.firstIndex(of: "("),
              let closeParenIndex = input.firstIndex(of: ")") else {
            return nil
        }
        
        let programName = String(input[..<openParenIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        let dateRange = String(input[input.index(after: openParenIndex)..<closeParenIndex])
        
        let inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "MM-dd-yyyy"
        inputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputDateFormatter = DateFormatter()
        outputDateFormatter.dateFormat = "MMMM d"
        
        let dates = dateRange.split(separator: "|")
        
        guard dates.count == 2,
              let startDate = inputDateFormatter.date(from: String(dates[0])),
              let endDate = inputDateFormatter.date(from: String(dates[1])) else {
            return nil
        }
        
        let formattedStartDate = outputDateFormatter.string(from: startDate)
        let formattedEndDate = outputDateFormatter.string(from: endDate)
        
        print("\(programName): \(formattedStartDate) - \(formattedEndDate)")
        return "\(programName): \(formattedStartDate) - \(formattedEndDate)"
    }
}
