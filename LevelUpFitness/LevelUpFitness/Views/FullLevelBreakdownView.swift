import SwiftUI
import Charts

struct FullLevelBreakdownView: View {
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var trendManager = TrendManager.shared
    
    let gradient = LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    let sublevelKeys = [
        "Lower Body Compound",
        "Lower Body Isolation",
        "Upper Body Compound",
        "Upper Body Isolation"
    ]

    
    @State var maxValue: Double = 0
    @State var minDate: Date = Date()
    @State var maxDate: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(gradient)
                        .frame(height: 200)
                        .shadow(radius: 10)
                    
                    VStack {
                        Text("Level \(xpManager.userXPData?.level ?? 0)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("XP: \(xpManager.userXPData?.xp ?? 0) / \(xpManager.userXPData?.xpNeeded ?? 0)")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                        
                        ProgressView(value: Float(xpManager.userXPData?.xp ?? 0), total: Float(xpManager.userXPData?.xpNeeded ?? 1))
                            .progressViewStyle(GaugeProgressStyle())
                            .frame(width: 200, height: 20)
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Core Sublevels")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(sublevelKeys, id: \.self) { key in
                        if let attribute = xpManager.userXPData?.subLevels.attribute(for: key) {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(key)
                                        .font(.headline)
                                    Spacer()
                                    Text("Level \(attribute.level)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                ProgressView(value: Float(attribute.xp), total: Float(attribute.xpNeeded))
                                    .progressViewStyle(LinearProgressStyle())
                                
                                Text("\(attribute.xp) / \(attribute.xpNeeded) XP")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }
                }
                
                if trendManager.levelTrend.count > 0 {
                    Chart(trendManager.levelTrend) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Level", dataPoint.value)
                        )
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Level", dataPoint.value)
                        )
                    }
                    .chartXScale(domain: minDate...maxDate)
                    .chartYScale(domain: 0...maxValue)
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Level Changes")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(levelChangeManager.levelChanges, id: \.id) { change in
                        HStack(spacing: 15) {
                            Image(systemName: iconName(for: change.keyword))
                                .font(.title)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(change.keyword)
                                    .font(.headline)
                                Text(change.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("XP Gained: \(change.change)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitle("Level Breakdown", displayMode: .inline)
        .onAppear {
            Task {
                await updateChartData()
            }
        }
    }
    
    private func iconName(for keyword: String) -> String {
        switch keyword {
        case "Weight": return "dollarsign.circle"
        case "Rest": return "bed.double"
        case "Endurance": return "heart.circle"
        case "Consistency": return "chart.bar"
        case "Challenge": return "flag.filled.and.flag.crossed"
        case "Program": return "calendar"
        default: return "star"
        }
    }
    
    func updateChartData() async {
        if TrendManager.shared.levelTrend.isEmpty {
            await TrendManager.shared.getLevelTrend()
        }
        
        let sortedTrend = TrendManager.shared.levelTrend.sorted { $0.date < $1.date }
        
        maxValue = (sortedTrend.map { $0.value }.max() ?? 200) * 1.1
        minDate = sortedTrend.first?.date ?? Date()
        maxDate = Date()
    }
}

struct GaugeProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.3))
                .frame(height: 20)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 200, height: 20)
        }
    }
}

struct LinearProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration)
            .accentColor(.blue)
            .scaleEffect(x: 1, y: 2, anchor: .center)
    }
}

struct FullLevelBreakdownView_Previews: PreviewProvider {
    static var previews: some View {
        FullLevelBreakdownView()
    }
}
