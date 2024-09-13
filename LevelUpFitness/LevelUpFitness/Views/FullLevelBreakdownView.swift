import SwiftUI
import Charts

struct FullLevelBreakdownView: View {
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var trendManager = TrendManager.shared
    
    @State private var maxValue: Double = 0
    @State private var minDate: Date = Date()
    @State private var maxDate: Date = Date()
    
    let progressColors: [Color] = [
        Color(hex: "40C4FC"),
        Color(hex: "FF5252"),
        Color(hex: "9C27B0"),
        Color(hex: "FFEB3B")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Level")
                        .font(.system(size: 28, weight: .medium, design: .default))
                        .padding(.top, 15)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Level \(xpManager.userXPData?.level ?? 0)")
                                .font(.system(size: 28, weight: .bold, design: .default))
                            
                            Text("\(xpManager.userXPData?.xp ?? 0) / \(xpManager.userXPData?.xpNeeded ?? 0) XP")
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .stroke(Color(hex: "F5F5F5"), lineWidth: 10)
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(Float(xpManager.userXPData?.xp ?? 0) / Float(xpManager.userXPData?.xpNeeded ?? 1)))
                                .stroke(Color(hex: "40C4FC"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .frame(width: 80, height: 80)
                                .rotationEffect(.degrees(-90))
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sublevels")
                        .font(.system(size: 22, weight: .medium, design: .default))
                    
                    ForEach(Array(xpManager.userXPData?.subLevels.allAttributes().enumerated() ?? [].enumerated()), id: \.element.key) { index, sublevel in
                        let (key, attribute) = sublevel
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(key.capitalizingFirstLetter())
                                    .font(.system(size: 18, weight: .medium, design: .default))
                                Spacer()
                                Text("Level \(attribute.level)")
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                            }
                            
                            ProgressView(value: Float(attribute.xp), total: Float(attribute.xpNeeded))
                                .progressViewStyle(CustomProgressLevelViewStyle(progressColor: progressColors[index % progressColors.count]))
                                .frame(height: 8)
                            
                            Text("\(attribute.xp)/\(attribute.xpNeeded) XP")
                                .font(.system(size: 14, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Level Changes")
                        .font(.system(size: 22, weight: .medium, design: .default))
                    
                    if levelChangeManager.levelChanges.isEmpty {
                        Text("No recent level changes")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    } else {
                        ForEach(levelChangeManager.levelChanges.prefix(5), id: \.id) { change in
                            HStack {
                                Image(systemName: iconName(for: change.keyword))
                                    .foregroundColor(Color(hex: "40C4FC"))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(change.keyword)
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                    Text(change.description)
                                        .font(.system(size: 14, weight: .regular, design: .default))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("+\(change.change) XP")
                                    .font(.system(size: 16, weight: .medium, design: .default))
                                    .foregroundColor(Color(hex: "40C4FC"))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Level Trends")
                            .font(.system(size: 22, weight: .medium, design: .default))
                        
                        Spacer()
                    }
                    
                    if trendManager.levelTrend.isEmpty {
                        Text("No trend data available")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    } else {
                        Chart(trendManager.levelTrend) { dataPoint in
                            LineMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Level", dataPoint.value)
                            )
                            .interpolationMethod(.catmullRom)
                            .foregroundStyle(Color(hex: "40C4FC"))
                            
                            PointMark(
                                x: .value("Date", dataPoint.date),
                                y: .value("Level", dataPoint.value)
                            )
                            .foregroundStyle(Color(hex: "40C4FC"))
                        }
                        .chartXScale(domain: minDate...maxDate)
                        .chartYScale(domain: 0...maxValue)
                        .frame(height: 250)
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color.white)
        .navigationBarBackButtonHidden()
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
                Rectangle()
                    .foregroundColor(Color(hex: "F5F5F5"))
                    .frame(height: 8)
                
                Rectangle()
                    .foregroundColor(progressColor)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: 8)
            }
        }
    }
}

#Preview {
    FullLevelBreakdownView()
}
