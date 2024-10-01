//
//  GymSessionStatsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/30/24.
//

import SwiftUI

struct GymSessionStatsView: View {
    let session: GymSession
    
    @State private var selectedGraphType: SessionGraphType = .totalVolumeByExercise
    @State private var graphData: [StatPoint] = []
    @State private var maxValue: Double = 0.0
    @State private var accentColor = Color(hex: "40C4FC")
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack (spacing: 8) {
                sessionStatsSummaryView
                
                graphToggleView
                
//                if !graphData.isEmpty {
//                    GeometryReader { geometry in
//                        let width = geometry.size.width
//                        let height = geometry.size.height
//                        let maxValueAdjusted = maxValue * 1.1
//                        let minValueAdjusted = 0.0
//                        
//                        ZStack {
//                            VStack {
//                                ForEach(0..<6) { index in
//                                    let labelValue = maxValueAdjusted - CGFloat(index) * (maxValueAdjusted - minValueAdjusted) / 5
//                                    HStack {
//                                        Text(String(format: "%.1f", labelValue))
//                                            .font(.system(size: 10, weight: .light))
//                                            .foregroundColor(.gray)
//                                            .frame(width: 40, alignment: .leading)
//                                        Spacer()
//                                    }
//                                    .frame(height: height / 6)
//                                }
//                            }
//                            
//                            VStack {
//                                Spacer()
//                                HStack {
//                                    ForEach(0..<graphData.count, id: \.self) { index in
//                                        if index % 2 == 0 {
//                                            let date = graphData[index].date
//                                            Text(date, style: .date)
//                                                .font(.system(size: 10, weight: .light))
//                                                .foregroundColor(.gray)
//                                                .offset(x: index == 0 ? 10 : 0)
//                                        }
//                                        Spacer()
//                                    }
//                                }
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.bottom, 16)
//                            
//                            Path { path in
//                                if let firstPoint = graphData.first {
//                                    let firstX = CGFloat(0) / CGFloat(graphData.count - 1) * width
//                                    let firstY = (1 - CGFloat((firstPoint.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
//                                    path.move(to: CGPoint(x: firstX, y: firstY))
//                                    
//                                    for (index, point) in graphData.enumerated() {
//                                        let x = CGFloat(index) / CGFloat(graphData.count - 1) * width
//                                        let y = (1 - CGFloat((point.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
//                                        path.addLine(to: CGPoint(x: x, y: y))
//                                    }
//                                }
//                            }
//                            .stroke(accentColor, lineWidth: 2)
//                            
//                            ForEach(graphData) { point in
//                                let index = graphData.firstIndex(where: { $0.id == point.id })!
//                                let x = CGFloat(index) / CGFloat(graphData.count - 1) * width
//                                let y = (1 - CGFloat((point.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
//                                
//                                Circle()
//                                    .fill(accentColor)
//                                    .frame(width: 8, height: 8)
//                                    .position(x: x, y: y)
//                            }
//                        }
//                    }
//                    .frame(height: 200)
//                    .padding(.vertical, 16)
//                } else {
//                    Text("No data available for this graph.")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(.gray)
//                        .padding(.top, 20)
//                }
                
                Spacer()
            }
            .padding(.horizontal)
            .onAppear {
                updateGraphData()
            }
        }
    }

    private var sessionStatsSummaryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                statsRectangle(title: "Total Volume", value: String(format: "%.1f kg", session.totalVolume))
                statsRectangle(title: "Total Reps", value: "\(session.totalReps)")
                statsRectangle(title: "Exercises", value: "\(session.totalExercisesCount)")
                statsRectangle(title: "Duration", value: String(format: "%.1f mins", (session.totalDuration ?? 0) / 60))
            }
        }
        .frame(height: 80)
        .background(Color.white)
    }

    private var graphToggleView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SessionGraphType.allCases, id: \.self) { graphType in
                    Button(action: {
                        selectedGraphType = graphType
                        updateGraphData()
                    }) {
                        Text(graphType.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedGraphType == graphType ? .white : Color(hex: "333333"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(height: 44) // Set uniform height for all buttons
                            .background(selectedGraphType == graphType ? accentColor : Color.white)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(accentColor, lineWidth: selectedGraphType == graphType ? 0 : 1)
                            )
                    }
                }
            }
        }
        .frame(height: 60)
        .background(Color.white)
    }

    private func statsRectangle(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "666666"))
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(hex: "333333"))
        }
        .frame(width: 100, height: 42)
        .padding()
        .background(Color(hex: "F5F5F5"))
    }

    private func updateGraphData() {
        switch selectedGraphType {
        case .totalVolumeByExercise:
            let volumeByExercise = session.totalVolumeByExerciseType.map { StatPoint(date: session.startTime, value: $0.value) }
            graphData = volumeByExercise
            maxValue = volumeByExercise.map { $0.value }.max() ?? 0.0
        case .totalRepsByExercise:
            let repsByExercise = session.totalRepsByExerciseType.map { StatPoint(date: session.startTime, value: Double($0.value)) }
            graphData = repsByExercise
            maxValue = repsByExercise.map { $0.value }.max() ?? 0.0
        }
    }
}

enum SessionGraphType: CaseIterable {
    case totalVolumeByExercise, totalRepsByExercise
    
    var displayName: String {
        switch self {
        case .totalVolumeByExercise: return "Volume by Exercise"
        case .totalRepsByExercise: return "Reps by Exercise"
        }
    }
}
