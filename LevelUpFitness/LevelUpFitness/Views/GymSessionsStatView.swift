import SwiftUI

struct GymSessionsStatsView: View {
    @ObservedObject var gymManager = GymManager.shared
    
    @State private var selectedGraphType: GraphType = .totalVolume
    @State private var graphData: [StatPoint] = []
    @State private var maxValue: Double = 0.0
    @State private var accentColor = Color(hex: "40C4FC")
    
    var body: some View {
           ZStack {
               Color.white.ignoresSafeArea()
               
               VStack(spacing: 8) {
                   statsSummaryView
                   graphToggleView
                   
                   if !graphData.isEmpty {
                       GeometryReader { geometry in
                           let width = geometry.size.width
                           let height = geometry.size.height
                           let maxValueAdjusted = maxValue * 1.1
                           let minValueAdjusted = 0.0
                           let yAxisWidth: CGFloat = 50 
                           let xAxisHeight: CGFloat = 40
                           let graphWidth = width - yAxisWidth
                           let graphHeight = height - xAxisHeight
                           
                           ZStack {
                               // Y-axis labels
                               VStack {
                                   ForEach(0..<6) { index in
                                       let labelValue = maxValueAdjusted - CGFloat(index) * (maxValueAdjusted - minValueAdjusted) / 5
                                       HStack {
                                           Text(formatValue(labelValue, for: selectedGraphType))
                                               .font(.system(size: 10, weight: .light))
                                               .foregroundColor(.gray)
                                               .frame(width: yAxisWidth - 5, alignment: .trailing) // Reduced width
                                           Spacer()
                                       }
                                       .frame(height: graphHeight / 6)
                                   }
                               }

                               // X-axis labels
                               VStack {
                                   Spacer()
                                   HStack(spacing: 0) { // Removed spacing
                                       ForEach(0..<graphData.count, id: \.self) { index in
                                           if index % 2 == 0 || index == graphData.count - 1 {
                                               let date = graphData[graphData.count - 1 - index].date
                                               Text(formatDate(date))
                                                   .font(.system(size: 10, weight: .light))
                                                   .foregroundColor(.gray)
                                                   .rotationEffect(.degrees(-45))
                                                   .offset(y: 20)
                                           }
                                           if index != graphData.count - 1 {
                                               Spacer()
                                           }
                                       }
                                   }
                                   .frame(width: graphWidth)
                               }

                               // Graph line
                               Path { path in
                                   if let firstPoint = graphData.last {
                                       let firstX = yAxisWidth
                                       let firstY = (1 - CGFloat((firstPoint.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * graphHeight
                                       path.move(to: CGPoint(x: firstX, y: firstY))
                                       
                                       for (index, point) in graphData.enumerated().reversed() {
                                           let x = CGFloat(graphData.count - 1 - index) / CGFloat(graphData.count - 1) * graphWidth + yAxisWidth
                                           let y = (1 - CGFloat((point.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * graphHeight
                                           path.addLine(to: CGPoint(x: x, y: y))
                                       }
                                   }
                               }
                               .stroke(accentColor, lineWidth: 2)
                               
                               // Data points
                               ForEach(graphData.indices, id: \.self) { index in
                                   let point = graphData[graphData.count - 1 - index]
                                   let x = CGFloat(index) / CGFloat(graphData.count - 1) * graphWidth + yAxisWidth
                                   let y = (1 - CGFloat((point.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * graphHeight
                                   
                                   Circle()
                                       .fill(accentColor)
                                       .frame(width: 8, height: 8)
                                       .position(x: x, y: y)
                               }
                           }
                       }
                       .frame(height: 200)
                       .padding(.vertical, 16)
                   } else {
                       Text("No data available for this graph.")
                           .font(.system(size: 14, weight: .medium))
                           .foregroundColor(.gray)
                           .padding(.top, 20)
                   }
                   
                   Spacer()
               }
               .onAppear {
                   updateGraphData()
               }
           }
       }

    private var statsSummaryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                statsRectangle(title: "Total Sessions", value: "\(gymManager.gymSessions.totalNumberOfSessions)")
                statsRectangle(title: "Total Volume", value: String(format: "%.1f lbs", gymManager.gymSessions.totalVolumeLifted))
                statsRectangle(title: "Total Time", value: String(format: "%.1f hrs", gymManager.gymSessions.totalTimeSpentWorkingOut / 3600))
                statsRectangle(title: "Avg Volume/Session", value: String(format: "%.1f lbs", gymManager.gymSessions.averageVolumePerSession))
                statsRectangle(title: "Avg Duration", value: String(format: "%.1f mins", gymManager.gymSessions.averageSessionDuration / 60))
            }
        }
        .frame(height: 80)
        .background(Color.white)
    }

    private var graphToggleView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GraphType.allCases, id: \.self) { graphType in
                    Button(action: {
                        selectedGraphType = graphType
                        updateGraphData()
                    }) {
                        Text(graphType.displayName)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(selectedGraphType == graphType ? .white : Color(hex: "333333"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(height: 44)
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
        maxValue = graphData.map { $0.value }.max() ?? 0.0
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM. d"
        return formatter.string(from: date)
    }
    
    private func formatValue(_ value: Double, for graphType: GraphType) -> String {
            switch graphType {
            case .totalVolume, .averageVolumePerSession:
                return String(format: "%.1f lbs", value)
            case .totalReps, .sessionCount:
                return String(format: "%.0f", value)
            case .averageDuration:
                return String(format: "%.1f min", value)
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
