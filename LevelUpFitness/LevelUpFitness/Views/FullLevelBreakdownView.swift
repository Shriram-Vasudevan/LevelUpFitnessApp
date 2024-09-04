import SwiftUI
import Charts

struct FullLevelBreakdownView: View {
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var trendManager = TrendManager.shared
    
    let gradient = LinearGradient(colors: [Color(hex: "3B82F6"), Color(hex: "1E40AF")], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    @State private var maxValue: Double = 0
    @State private var minDate: Date = Date()
    @State private var maxDate: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overviewSection
                sublevelsSection
                trendsSection
                recentChangesSection
            }
            .padding()
        }
        .background(Color(hex: "F0F4F8"))
        .navigationBarTitle("Level Breakdown", displayMode: .inline)
        .onAppear {
            Task {
                await updateChartData()
            }
        }
    }
    
    private var overviewSection: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "CBD5E1"), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: CGFloat(Float(xpManager.userXPData?.xp ?? 0) / Float(xpManager.userXPData?.xpNeeded ?? 1)))
                    .stroke(gradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 4) {
                    Text("Level")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "64748B"))
                    Text("\(xpManager.userXPData?.level ?? 0)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "1E293B"))
                }
            }
            .frame(width: 100, height: 100)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("XP Progress")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "1E293B"))
                Text("\(xpManager.userXPData?.xp ?? 0) / \(xpManager.userXPData?.xpNeeded ?? 0)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "64748B"))
                ProgressView(value: Float(xpManager.userXPData?.xp ?? 0), total: Float(xpManager.userXPData?.xpNeeded ?? 1))
                    .progressViewStyle(CustomProgressLevelViewStyle())
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var sublevelsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sublevels")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "1E293B"))
            
            ForEach(xpManager.userXPData?.subLevels.allAttributes() ?? [], id: \.key) { key, attribute in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1E293B"))
                        Text("Level \(attribute.level)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                    Spacer()
                    Text("\(attribute.xp)/\(attribute.xpNeeded)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "64748B"))
                }
                ProgressView(value: Float(attribute.xp), total: Float(attribute.xpNeeded))
                    .progressViewStyle(CustomProgressLevelViewStyle())
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var trendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Level Trends")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "1E293B"))
            
            if trendManager.levelTrend.count > 0 {
                Chart(trendManager.levelTrend) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Level", dataPoint.value)
                    )
                    .foregroundStyle(gradient)
                    PointMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Level", dataPoint.value)
                    )
                    .foregroundStyle(Color(hex: "3B82F6"))
                }
                .chartXScale(domain: minDate...maxDate)
                .chartYScale(domain: 0...maxValue)
                .frame(height: 200)
            } else {
                Text("No trend data available")
                    .foregroundColor(Color(hex: "64748B"))
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var recentChangesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Level Changes")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "1E293B"))
            
            ForEach(levelChangeManager.levelChanges.prefix(5), id: \.id) { change in
                HStack(spacing: 16) {
                    Image(systemName: iconName(for: change.keyword))
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(gradient)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(change.keyword)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "1E293B"))
                        Text(change.description)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "64748B"))
                    }
                    
                    Spacer()
                    
                    Text("+\(change.change) XP")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "10B981"))
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
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
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(hex: "E2E8F0"))
                    .cornerRadius(5)
                
                Rectangle()
                    .foregroundColor(Color(hex: "3B82F6"))
                    .cornerRadius(5)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width)
            }
        }
        .frame(height: 10)
    }
}

struct FullLevelBreakdownView_Previews: PreviewProvider {
    static var previews: some View {
        FullLevelBreakdownView()
    }
}
