import SwiftUI
import Charts

struct GymSessionsStatsView: View {
    @ObservedObject var gymManager = GymManager.shared

    @State private var selectedGraphType: GraphType = .totalVolume
    @State private var graphData: [StatPoint] = []

    private let accent = Color(hex: "0B5ED7")

    var body: some View {
        VStack(spacing: 14) {
            statsSummaryView
            graphToggleView
            chartSection
        }
        .onAppear {
            updateGraphData()
        }
        .onChange(of: selectedGraphType) {
            updateGraphData()
        }
    }

    private var statsSummaryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                statsRectangle(title: "Sessions", value: "\(gymManager.gymSessions.totalNumberOfSessions)")
                statsRectangle(title: "Volume", value: String(format: "%.0f lbs", gymManager.gymSessions.totalVolumeLifted))
                statsRectangle(title: "Time", value: String(format: "%.1f hr", gymManager.gymSessions.totalTimeSpentWorkingOut / 3600))
                statsRectangle(title: "Avg Volume", value: String(format: "%.0f lbs", gymManager.gymSessions.averageVolumePerSession))
                statsRectangle(title: "Avg Duration", value: String(format: "%.1f min", gymManager.gymSessions.averageSessionDuration / 60))
            }
        }
    }

    private var graphToggleView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GraphType.allCases, id: \.self) { graphType in
                    Button(action: {
                        selectedGraphType = graphType
                    }) {
                        Text(graphType.displayName)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(selectedGraphType == graphType ? .white : accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
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
    }

    private var chartSection: some View {
        Group {
            if graphData.isEmpty {
                Text("No data available for this graph.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 4)
            } else {
                Chart(graphData) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value(selectedGraphType.displayName, point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [accent.opacity(0.24), accent.opacity(0.03)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value(selectedGraphType.displayName, point.value)
                    )
                    .foregroundStyle(accent)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value(selectedGraphType.displayName, point.value)
                    )
                    .foregroundStyle(accent)
                }
                .frame(height: 210)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [3]))
                        AxisTick()
                        AxisValueLabel {
                            if let y = value.as(Double.self) {
                                Text(formatValue(y, for: selectedGraphType))
                                    .font(.system(size: 10, weight: .medium))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, graphData.count / 4))) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.4, dash: [3]))
                        AxisTick()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
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
        .frame(width: 120, alignment: .leading)
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
        case .totalVolume:
            graphData = gymManager.gymSessions.totalVolumeOverTime()
        case .totalReps:
            graphData = gymManager.gymSessions.totalRepsOverTime()
        case .sessionCount:
            graphData = gymManager.gymSessions.totalSessionsPerWeek()
        case .averageDuration:
            graphData = gymManager.gymSessions.averageDurationOverTime()
        case .averageVolumePerSession:
            graphData = gymManager.gymSessions.averageVolumePerSessionOverTime()
        }
        graphData.sort { $0.date < $1.date }
    }

    private func formatValue(_ value: Double, for graphType: GraphType) -> String {
        switch graphType {
        case .totalVolume, .averageVolumePerSession:
            return String(format: "%.0f", value)
        case .totalReps, .sessionCount:
            return String(format: "%.0f", value)
        case .averageDuration:
            return String(format: "%.1f", value)
        }
    }
}

enum GraphType: CaseIterable {
    case totalVolume, totalReps, sessionCount, averageDuration, averageVolumePerSession

    var displayName: String {
        switch self {
        case .totalVolume: return "Total Volume"
        case .totalReps: return "Total Reps"
        case .sessionCount: return "Session Count"
        case .averageDuration: return "Avg Duration"
        case .averageVolumePerSession: return "Avg Volume/Session"
        }
    }
}
