//
//  GymSessionStatsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/30/24.
//

import SwiftUI
import Charts

struct GymSessionStatsView: View {
    let session: GymSession

    @State private var selectedGraphType: SessionGraphType = .totalVolumeByExercise
    @State private var graphData: [SessionExerciseStat] = []

    private let accent = Color(hex: "0B5ED7")

    var body: some View {
        VStack(spacing: 12) {
            sessionStatsSummaryView
            graphToggleView
            chartView
        }
        .onAppear {
            updateGraphData()
        }
        .onChange(of: selectedGraphType) {
            updateGraphData()
        }
    }

    private var sessionStatsSummaryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                statsRectangle(title: "Volume", value: String(format: "%.0f lbs", session.totalVolume))
                statsRectangle(title: "Reps", value: "\(session.totalReps)")
                statsRectangle(title: "Exercises", value: "\(session.totalExercisesCount)")
                statsRectangle(title: "Duration", value: String(format: "%.1f min", (session.totalDuration ?? 0) / 60))
            }
        }
    }

    private var graphToggleView: some View {
        HStack(spacing: 8) {
            ForEach(SessionGraphType.allCases, id: \.self) { graphType in
                Button(action: {
                    selectedGraphType = graphType
                }) {
                    Text(graphType.displayName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedGraphType == graphType ? .white : accent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(selectedGraphType == graphType ? accent : Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(accent.opacity(selectedGraphType == graphType ? 0 : 0.45), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var chartView: some View {
        Group {
            if graphData.isEmpty {
                Text("No exercise data available for this session.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            } else {
                Chart(graphData) { point in
                    BarMark(
                        x: .value("Exercise", point.label),
                        y: .value(selectedGraphType.displayName, point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent, Color(hex: "40C4FC")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(3)
                }
                .frame(height: 210)
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.35, dash: [2]))
                        AxisTick()
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .lineLimit(1)
                                    .font(.system(size: 10, weight: .medium))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            }
        }
    }

    private func statsRectangle(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color(hex: "6B7280"))
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "111827"))
        }
        .frame(width: 118, alignment: .leading)
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func updateGraphData() {
        switch selectedGraphType {
        case .totalVolumeByExercise:
            graphData = session.totalVolumeByExerciseType
                .map { SessionExerciseStat(label: $0.key, value: $0.value) }
                .sorted { $0.value > $1.value }
        case .totalRepsByExercise:
            graphData = session.totalRepsByExerciseType
                .map { SessionExerciseStat(label: $0.key, value: Double($0.value)) }
                .sorted { $0.value > $1.value }
        }
    }
}

private struct SessionExerciseStat: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
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
