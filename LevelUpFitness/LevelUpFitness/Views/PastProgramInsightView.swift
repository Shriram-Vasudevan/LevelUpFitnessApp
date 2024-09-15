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
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack (spacing: 0) {
                ZStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.primary)
                        }
                        
                    }
                    .padding()
                    
                    Text("Program Insights")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
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
            }
        }
        .navigationBarBackButtonHidden()
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
        .background(Color(hex: "F5F5F5"))
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
                            .background(Color(hex: "40C4FC"))
                        
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
    @State private var selectedPoint: DayCompletion?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily Completion")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let maxValue = (dayCompletions.map { $0.percentage }.max() ?? 0) * 1.1
                let minValue = (dayCompletions.map { $0.percentage }.min() ?? 0) * 0.9
                
                ZStack {
                    VStack {
                        ForEach(0..<6) { index in
                            let labelValue = maxValue - CGFloat(index) * (maxValue - minValue) / 5
                            HStack {
                                Text(String(format: "%.0f%%", labelValue))
                                    .font(.system(size: 10, weight: .light))
                                    .foregroundColor(.gray)
                                    .frame(width: 30, alignment: .trailing)
                                Spacer()
                            }
                            .frame(height: height / 6)
                        }
                    }

                    VStack {
                        Spacer()
                        HStack {
                            ForEach(0..<dayCompletions.count, id: \.self) { index in
                                if index % 2 == 0 {
                                    Text(dayCompletions[index].day.prefix(1))
                                        .font(.system(size: 10, weight: .light))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 16)
                
                    Path { path in
                        if let firstPoint = dayCompletions.first {
                            let firstX = CGFloat(0) / CGFloat(dayCompletions.count - 1) * (width - 30) + 30
                            let firstY = (1 - CGFloat((firstPoint.percentage - minValue) / (maxValue - minValue))) * height
                            path.move(to: CGPoint(x: firstX, y: firstY))
                            
                            for (index, point) in dayCompletions.enumerated() {
                                let x = CGFloat(index) / CGFloat(dayCompletions.count - 1) * (width - 30) + 30
                                let y = (1 - CGFloat((point.percentage - minValue) / (maxValue - minValue))) * height
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color(hex: "40C4FC"), lineWidth: 2)
                    
                    ForEach(dayCompletions) { point in
                        let index = dayCompletions.firstIndex(where: { $0.id == point.id })!
                        let x = CGFloat(index) / CGFloat(dayCompletions.count - 1) * (width - 30) + 30
                        let y = (1 - CGFloat((point.percentage - minValue) / (maxValue - minValue))) * height
                        
                        Circle()
                            .fill(Color(hex: "40C4FC"))
                            .frame(width: 8, height: 8)
                            .position(x: x, y: y)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { _ in selectedPoint = point }
                                    .onEnded { _ in selectedPoint = nil }
                            )
                    }
                    
                    if let selectedPoint = selectedPoint {
                        let index = dayCompletions.firstIndex(where: { $0.id == selectedPoint.id })!
                        let x = CGFloat(index) / CGFloat(dayCompletions.count - 1) * (width - 30) + 30
                        let y = (1 - CGFloat((selectedPoint.percentage - minValue) / (maxValue - minValue))) * height
                        
                        VStack {
                            Text("\(selectedPoint.day)")
                                .font(.caption)
                            Text(String(format: "%.1f%%", selectedPoint.percentage))
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                        .position(x: x, y: max(y - 40, 20))
                    }
                }
            }
            .frame(height: 200)
            .padding(.vertical, 16)
        }
    }
}


#Preview {
    PastProgramInsightView(programS3Representation: "Muscle Maximization")
}
