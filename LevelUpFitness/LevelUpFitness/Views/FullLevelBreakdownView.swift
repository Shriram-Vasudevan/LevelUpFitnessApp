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
    
    private let accentColor = Color(hex: "40C4FC")
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack (spacing: 12) {
                    HStack {
                        Text("My Level")
                            .font(.system(size: 28, weight: .medium, design: .default))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.top, 15)
                    
                    LevelWidget(xpManager: xpManager, levelChangeManager: levelChangeManager)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Sublevels")
                        .font(.custom("Poppins-SemiBold", size: 22))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Array(xpManager.userXPData?.subLevels.allAttributes().enumerated() ?? [].enumerated()), id: \.element.key) { index, sublevel in
                                let (key, attribute) = sublevel
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(key.capitalizingFirstLetter())
                                            .font(.custom("Poppins-SemiBold", size: 18))
                                        Spacer()
                                        Text("Level \(attribute.level)")
                                            .font(.custom("Poppins-Regular", size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    ProgressView(value: Float(attribute.xp), total: Float(attribute.xpNeeded))
                                        .progressViewStyle(CustomProgressLevelViewStyle(progressColor: progressColors[index % progressColors.count]))
                                        .frame(height: 8)
                                    
                                    Text("\(attribute.xp)/\(attribute.xpNeeded) XP")
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(hex: "F5F5F5"))
                                .cornerRadius(2)
                                .frame(width: 200)
                            }
                        }
                    }
                }
            
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Recent Level Changes")
                            .font(.custom("Poppins-SemiBold", size: 22))
                        
                        Spacer()
                    }
                    
                    if levelChangeManager.levelChanges.isEmpty {
                        Text("No recent level changes")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.gray)
                    } else {
                        ForEach(levelChangeManager.levelChanges.prefix(5), id: \.id) { change in
                            HStack {
                                Image(systemName: iconName(for: change.keyword))
                                    .foregroundColor(Color(hex: "40C4FC"))
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(change.keyword)
                                        .font(.custom("Poppins-SemiBold", size: 16))
                                    Text(change.description)
                                        .font(.custom("Poppins-Regular", size: 14))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Text("+\(change.change) XP")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                                    .foregroundColor(Color(hex: "40C4FC"))
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Level Trends")
                            .font(.custom("Poppins-SemiBold", size: 22))
                        
                        Spacer()
                    }
                    
                    if trendManager.levelTrend.isEmpty {
                        Text("No trend data available")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.gray)
                    } else {
                        customTable()
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
    
    private func customTable() -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let maxValue = (trendManager.levelTrend.map { $0.value }.max() ?? 0) * 1.1
            let minValue = (trendManager.levelTrend.map { $0.value }.min() ?? 0) * 0.9
            
            ZStack {
                VStack {
                    ForEach(0..<6) { index in
                        let labelValue = maxValue - CGFloat(index) * (maxValue - minValue) / 5
                        HStack {
                            Text(String(format: "%.1f", labelValue))
                                .font(.system(size: 10, weight: .light, design: .default))
                                .foregroundColor(.gray)
                                .frame(width: 40, alignment: .leading)
                            Spacer()
                        }
                        .frame(height: height / 6)
                    }
                }
                
                VStack {
                    Spacer()
                    HStack {
                        ForEach(0..<trendManager.levelTrend.count, id: \.self) { index in
                            if index % 2 == 0 {
                                let date = trendManager.levelTrend[index].date
                                Text(date, style: .date)
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .foregroundColor(.gray)
                                    .offset(x: index == 0 ? 10 : 0)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            
                Path { path in
                    if let firstPoint = trendManager.levelTrend.first {
                        let firstX = CGFloat(0) / CGFloat(trendManager.levelTrend.count - 1) * width
                        let firstY = (1 - CGFloat((firstPoint.value - minValue) / (maxValue - minValue))) * height
                        path.move(to: CGPoint(x: firstX, y: firstY))
                        
                        for (index, point) in trendManager.levelTrend.enumerated() {
                            let x = CGFloat(index) / CGFloat(trendManager.levelTrend.count - 1) * width
                            let y = (1 - CGFloat((point.value - minValue) / (maxValue - minValue))) * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.addLine(to: CGPoint(x: 0, y: height))
                        path.closeSubpath()
                    }
                }
                .fill(accentColor.opacity(0.2))
                
                Path { path in
                    if let firstPoint = trendManager.levelTrend.first {
                        let firstX = CGFloat(0) / CGFloat(trendManager.levelTrend.count - 1) * width
                        let firstY = (1 - CGFloat((firstPoint.value - minValue) / (maxValue - minValue))) * height
                        path.move(to: CGPoint(x: firstX, y: firstY))
                        
                        for (index, point) in trendManager.levelTrend.enumerated() {
                            let x = CGFloat(index) / CGFloat(trendManager.levelTrend.count - 1) * width
                            let y = (1 - CGFloat((point.value - minValue) / (maxValue - minValue))) * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(accentColor, lineWidth: 2)
                
                ForEach(trendManager.levelTrend) { point in
                    let index = trendManager.levelTrend.firstIndex(where: { $0.id == point.id })!
                    let x = CGFloat(index) / CGFloat(trendManager.levelTrend.count - 1) * width
                    let y = (1 - CGFloat((point.value - minValue) / (maxValue - minValue))) * height
                    
                    Circle()
                        .fill(accentColor)
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
        .frame(height: 200)
        .padding(.vertical, 16)
        
    }
    // MARK: - Helper Functions
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
        
        if let userXPData = xpManager.userXPData {
            TrendManager.shared.levelTrend.append(HealthDataPoint(date: Date(), value: Double(userXPData.level)))
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

struct LevelWidget: View {
    @ObservedObject var xpManager: XPManager
    @ObservedObject var levelChangeManager: LevelChangeManager
    
    private let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "87CEFA")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private var recentChangeSum: Int {
        levelChangeManager.levelChanges.prefix(4).reduce(0) { $0 + $1.change }
    }
    
    private var changeIcon: String {
        if recentChangeSum > 0 {
            return "arrow.up"
        } else if recentChangeSum < 0 {
            return "arrow.down"
        } else {
            return "arrow.right"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .fill(gradient)
                    .frame(height: 160)
                
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LEVEL")
                                .font(.system(size: 14, weight: .semibold, design: .default))
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(xpManager.userXPData?.level ?? 0)")
                                .font(.system(size: 48, weight: .bold, design: .default))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Image(systemName: changeIcon)
                            .font(.system(size: 24, weight: .bold, design: .default))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 8) {
                        ProgressView(value: Float(xpManager.userXPData?.xp ?? 0), total: Float(xpManager.userXPData?.xpNeeded ?? 1))
                            .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        
                        HStack {
                            Text("\(xpManager.userXPData?.xp ?? 0) / \(xpManager.userXPData?.xpNeeded ?? 0) XP")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("Next Level: \((xpManager.userXPData?.level ?? 0) + 1)")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}


#Preview {
    FullLevelBreakdownView()
}
