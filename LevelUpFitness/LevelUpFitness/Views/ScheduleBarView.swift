//
//  ScheduleBarView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 11/23/24.
//

import SwiftUI

struct ScheduleBarView: View {
    @Binding var selectedDate: Date
    let startDate: String
    let program: [ProgramDay]
    private let lightBlue = Color(hex: "40C4FC")
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(-14...14, id: \.self) { offset in  
                    let date = Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
                    dateCell(for: date)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func dateCell(for date: Date) -> some View {
        let weekday = DateUtility.getWeekdayFromDate(
            date: date.formatted(.dateTime.month(.defaultDigits).day().year())
        )?.lowercased() ?? ""
        
        let programDay = program.first { $0.day.lowercased() == weekday }
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isPast = date < Date().startOfDay
        
        return VStack(alignment: .center, spacing: 8) {
            Text(date.formatted(.dateTime.month(.abbreviated).day()))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? lightBlue : .primary)
                .frame(height: 17) // Fixed height for month/day
            
            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(isSelected ? lightBlue : .secondary)
                .frame(height: 15) // Fixed height for weekday
            
            if isPast, let programDay = programDay {
                Circle()
                    .fill(programDay.completed ? lightBlue : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            } else {
                Color.clear.frame(height: 6) // Placeholder for consistent height
            }
        }
        .frame(width: 50, height: 70)
        .background(isSelected ? lightBlue.opacity(0.1) : Color.clear)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? lightBlue : Color.clear, lineWidth: 2)
        )
        .cornerRadius(12)
        .onTapGesture {
            withAnimation(.spring()) {
                selectedDate = date
            }
        }
    }
}
