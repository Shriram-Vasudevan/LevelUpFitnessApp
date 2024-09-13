//
//  PastProgramInsightView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/23/24.
//
import SwiftUI

struct PastProgramInsightView: View {
    var programS3Representation: String
    @State private var programs: [Program]?
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    if let programs = self.programs {
                        ForEach(Array(programs.enumerated()), id: \.offset) { index, program in
                            WeekInsightCard(program: program, weekNumber: index + 1)
                        }
                    } else {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Program Insights")
        }
        .onAppear {
            Task {
                self.programs = await ProgramManager.shared.getProgramsForInsights(programS3Representation: programS3Representation)
            }
        }
    }
}

struct WeekInsightCard: View {
    let program: Program
    let weekNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Week \(weekNumber)")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.black)
            
            HStack(spacing: 20) {
                InsightCircle(
                    value: program.getProgramCompletionPercentage(),
                    label: "Completion"
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    InsightRow(title: "Total Workout Time", value: formatTime(program.getTotalWorkoutTime()))
                    InsightRow(title: "Avg. Workout Time", value: formatTime(program.getAverageWorkoutTime()))
                    InsightRow(title: "Total Weight Used", value: "\(program.getTotalWeightUsed()) kg")
                }
            }
            
            MuscleGroupBar(muscleGroups: program.getMostFrequentMuscleGroups())
            
            DailyCompletionChart(dayCompletions: program.getDayCompletionPercentages())
        }
        .padding()
        .background(Color(hex: "F5F5F5")) // Updated card background
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        return String(format: "%dh %dm", hours, minutes)
    }
}

struct InsightCircle: View {
    let value: Double
    let label: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(value / 100, 1)))
                    .stroke(Color(hex: "40C4FC"), style: StrokeStyle(lineWidth: 10, lineCap: .round)) // Light blue color
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                VStack {
                    Text(String(format: "%.0f%%", value))
                        .font(.system(size: 22, weight: .bold))
                    Text(label)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct InsightRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
        .font(.subheadline)
    }
}

struct MuscleGroupBar: View {
    let muscleGroups: [MuscleGroupStat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Most Targeted Muscle Groups")
                .font(.headline)
                .foregroundColor(.black)
            
            HStack(spacing: 0) {
                ForEach(muscleGroups.prefix(3), id: \.self) { group in
                    VStack {
                        Text("\(group.count)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "40C4FC")) // Light blue color
                        
                        Text(group.area)
                            .font(.caption2)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
        }
    }
}

struct DailyCompletionChart: View {
    let dayCompletions: [DayCompletion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Completion")
                .font(.headline)
                .foregroundColor(.black)
            
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(dayCompletions) { completion in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "40C4FC")) // Light blue color
                            .frame(height: CGFloat(completion.percentage))
                        Text(completion.day.prefix(1))
                            .font(.caption2)
                    }
                }
            }
            .frame(height: 100)
        }
    }
}

#Preview {
    PastProgramInsightView(programS3Representation: "Muscle Maximization")
}
