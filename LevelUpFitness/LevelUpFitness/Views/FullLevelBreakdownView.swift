import SwiftUI
import Charts

struct FullLevelBreakdownView: View {
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var trendManager = TrendManager.shared
    
    let gradient = LinearGradient(colors: [Color(hex: "3B82F6"), Color(hex: "60A5FA")], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    @State private var maxValue: Double = 0
    @State private var minDate: Date = Date()
    @State private var maxDate: Date = Date()
    
    // Define the colors to be used in rotation for the progress bars
    let progressColors: [Color] = [
        Color(hex: "#40C4FC"),
        Color(hex: "#FF5252"),
        Color(hex: "#9C27B0"),
        Color(hex: "#FFEB3B")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ZStack {
                    VStack(spacing: 10) {
                        HStack {
                            Text("Level")
                                .font(.system(size: 48, weight: .light, design: .rounded))
                                .foregroundColor(.black)
                            
                            ZStack {
                                Circle()
                                    .trim(from: 0, to: CGFloat(Float(xpManager.userXPData?.xp ?? 0) / Float(xpManager.userXPData?.xpNeeded ?? 1)))
                                    .stroke(Color(hex: "40C4FC"), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                    .rotationEffect(.degrees(-90))
                                    .frame(width: 37, height: 37)
                                
                                Text("\(xpManager.userXPData?.level ?? 0)")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Text("\(xpManager.userXPData?.xp ?? 0) / \(xpManager.userXPData?.xpNeeded ?? 0) XP")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.black)
                    }
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("Sublevels")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.gray)
                    
                    ForEach(Array(xpManager.userXPData?.subLevels.allAttributes().enumerated() ?? [].enumerated()), id: \.element.key) { index, sublevel in
                        let (key, attribute) = sublevel
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(key): \(attribute.level)")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("\(attribute.xp)/\(attribute.xpNeeded) XP")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            
                            ProgressView(value: Float(attribute.xp), total: Float(attribute.xpNeeded))
                                .progressViewStyle(CustomProgressLevelViewStyle(progressColor: progressColors[index % progressColors.count]))
                                .frame(height: 8)
                                .background(Capsule().fill(Color(hex: "E0F2FE")))
                        }
                    }
                }
                
                if levelChangeManager.levelChanges.count > 0 {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Recent Level Changes")
                            .font(.system(size: 24, weight: .light, design: .rounded))
                            .foregroundColor(.gray)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(levelChangeManager.levelChanges.prefix(5), id: \.id) { change in
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(change.keyword)
                                            .font(.system(size: 18, weight: .medium, design: .rounded))
                                            .foregroundColor(.black)
                                        
                                        Text(change.description)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(.black.opacity(0.7))
                                        
                                        Text("\(change.change) XP")
                                            .font(.system(size: 18, weight: .light, design: .rounded))
                                            .foregroundColor(Color(hex: "10B981"))
                                    }
                                    .padding()
                                    .background(Color(hex: "F5F5F5"))
                                    .cornerRadius(15)
                                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
            
                VStack(alignment: .leading, spacing: 10) {
                    Text("Level Trends")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.gray)
                    
                    if trendManager.levelTrend.count > 0 {
                        Chart(trendManager.levelTrend) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Level", dataPoint.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(gradient)
                            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                            
                            PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Level", dataPoint.value)
                            )
                            .foregroundStyle(Color(hex: "60A5FA"))
                            .symbolSize(30)
                        }
                        .chartXScale(domain: minDate...maxDate)
                        .chartYScale(domain: 0...maxValue)
                        .frame(height: 250)
                    } else {
                        Text("No trend data available")
                            .foregroundColor(Color(hex: "64748B"))
                    }
                }
                .padding(.top, -10)
            }
            .padding()
        }
        .background(Color.white.ignoresSafeArea())
        .navigationBarTitle("Level Breakdown", displayMode: .inline)
        .onAppear {
            Task {
                await updateChartData()
            }
        }
    }


    private func iconName(for keyword: String) -> String {
        switch keyword {
        case "Weight": return "scalemass.fill"
        case "Rest": return "bed.double.fill"
        case "Endurance": return "flame.fill"
        case "Consistency": return "chart.bar.fill"
        case "Challenge": return "trophy.fill"
        case "Program": return "calendar"
        default: return "star.fill"
        }
    }
    
    private func updateChartData() async {
        if TrendManager.shared.levelTrend.isEmpty {
            await TrendManager.shared.getLevelTrend()
        }
        
        let sortedTrend = TrendManager.shared.levelTrend.sorted { $0.date < $1.date }
        
        maxValue = (sortedTrend.map { $0.value }.max() ?? 200) * 1.1
        minDate = sortedTrend.first?.date ?? Date()
        maxDate = Date()
    }
}

struct CustomProgressLevelViewStyle: ProgressViewStyle {
    var progressColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .foregroundColor(progressColor.opacity(0.3))
                    .frame(height: 8)
                
                Capsule()
                    .foregroundColor(progressColor)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width)
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    FullLevelBreakdownView()
}
