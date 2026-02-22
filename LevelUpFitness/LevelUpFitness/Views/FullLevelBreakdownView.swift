import SwiftUI
import Charts

struct FullLevelBreakdownView: View {
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var trendManager = TrendManager.shared

    @State private var levelTrendPoints: [HealthDataPoint] = []

    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    titleHeader
                    levelHeroCard
                    sublevelSection
                    sublevelDistributionSection
                    recentChangesSection
                    trendSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .navigationBarBackButtonHidden()
        .task {
            await refreshData()
        }
    }

    private var titleHeader: some View {
        HStack {
            Text("Level Breakdown")
                .font(AppTheme.Typography.telemetry(size: 30, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            Spacer()
        }
    }

    private var levelHeroCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Level")
                        .font(AppTheme.Typography.telemetry(size: 13, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textSecondary)

                    Text("\(xpManager.userXPData?.level ?? 1)")
                        .font(AppTheme.Typography.monumentalNumber(size: 46))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .controlledGlow(isActive: true)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Recent XP Delta")
                        .font(AppTheme.Typography.telemetry(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textSecondary)
                    HStack(spacing: 4) {
                        Image(systemName: deltaIcon)
                        Text(deltaLabel)
                    }
                    .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                    .foregroundColor(recentDelta >= 0 ? AppTheme.Colors.success : AppTheme.Colors.danger)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(xpManager.userXPData?.xp ?? 0) XP")
                    Spacer()
                    Text("Next: \(xpManager.userXPData?.xpNeeded ?? 1) XP")
                }
                .font(AppTheme.Typography.telemetry(size: 12, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textSecondary)

                ProgressView(value: levelProgress)
                    .progressViewStyle(.linear)
                    .tint(AppTheme.Colors.bluePrimary)
                    .scaleEffect(x: 1, y: 1.35, anchor: .center)
            }
        }
        .padding(16)
        .engineeredPanel(isElevated: true)
    }

    private var sublevelSection: some View {
        DashboardSection(title: "Sublevel Progress") {
            if sublevels.isEmpty {
                emptyState("Sublevel data is not available yet.")
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(sublevels) { sublevel in
                        SublevelCard(sublevel: sublevel)
                    }
                }
            }
        }
    }

    private var sublevelDistributionSection: some View {
        DashboardSection(title: "Sublevel Distribution") {
            if sublevels.isEmpty {
                emptyState("Complete more sessions to populate sublevel distribution.")
            } else {
                Chart(sublevels) { sublevel in
                    BarMark(
                        x: .value("Category", sublevel.shortName),
                        y: .value("Completion", sublevel.completion * 100)
                    )
                    .foregroundStyle(AppTheme.Lighting.activeGradient)
                    .cornerRadius(3)
                }
                .frame(height: 200)
                .chartYScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.35, dash: [2]))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisTick()
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel {
                            if let y = value.as(Double.self) {
                                Text("\(Int(y))%")
                                    .font(AppTheme.Typography.telemetry(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let x = value.as(String.self) {
                                Text(x)
                                    .font(AppTheme.Typography.telemetry(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private var recentChangesSection: some View {
        DashboardSection(title: "Recent Level Changes") {
            if levelChangeManager.levelChanges.isEmpty {
                emptyState("No recent level changes.")
            } else {
                VStack(spacing: 8) {
                    ForEach(Array(levelChangeManager.levelChanges.suffix(6).reversed()), id: \.id) { change in
                        HStack(spacing: 12) {
                            Image(systemName: iconName(for: change.keyword))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.Colors.bluePrimary)
                                .frame(width: 32, height: 32)
                                .background(AppTheme.Colors.bluePrimary.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(change.keyword)
                                    .font(AppTheme.Typography.telemetry(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textPrimary)
                                Text(change.description)
                                    .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                    .lineLimit(2)
                                Text(formattedTimestamp(change.timestamp))
                                    .font(AppTheme.Typography.telemetry(size: 11, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textDisabled)
                            }

                            Spacer()

                            Text(signedXP(change.change))
                                .font(AppTheme.Typography.monumentalNumber(size: 14))
                                .foregroundColor(change.change >= 0 ? AppTheme.Colors.success : AppTheme.Colors.danger)
                        }
                        .padding(12)
                        .background(AppTheme.Colors.surfaceLight)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous)
                                .stroke(Color.white.opacity(0.04), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    private var trendSection: some View {
        DashboardSection(title: "Level Trend (30d)") {
            if levelTrendPoints.isEmpty {
                emptyState("No trend data available.")
            } else {
                Chart(levelTrendPoints) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Level", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.Colors.bluePrimary.opacity(0.24), AppTheme.Colors.bluePrimary.opacity(0.03)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Level", point.value)
                    )
                    .foregroundStyle(AppTheme.Colors.bluePrimary)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Level", point.value)
                    )
                    .foregroundStyle(AppTheme.Colors.bluePrimary)
                }
                .frame(height: 220)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.35, dash: [2]))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisTick()
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel {
                            if let y = value.as(Double.self) {
                                Text(String(format: "%.0f", y))
                                    .font(AppTheme.Typography.telemetry(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(1, levelTrendPoints.count / 4))) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.35, dash: [2]))
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisTick()
                            .foregroundStyle(Color.white.opacity(0.1))
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(.dateTime.month(.abbreviated).day()))
                                    .font(AppTheme.Typography.telemetry(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.Colors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
    }

    private func emptyState(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Typography.telemetry(size: 13, weight: .medium))
            .foregroundColor(AppTheme.Colors.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(AppTheme.Colors.surfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.04), lineWidth: 1)
            )
    }

    private var levelProgress: Double {
        guard let xp = xpManager.userXPData?.xp, let xpNeeded = xpManager.userXPData?.xpNeeded, xpNeeded > 0 else {
            return 0
        }
        return min(max(Double(xp) / Double(xpNeeded), 0), 1)
    }

    private var recentDelta: Int {
        levelChangeManager.levelChanges.suffix(4).reduce(0) { $0 + $1.change }
    }

    private var deltaIcon: String {
        if recentDelta > 0 { return "arrow.up.right" }
        if recentDelta < 0 { return "arrow.down.right" }
        return "arrow.right"
    }

    private var deltaLabel: String {
        signedXP(recentDelta)
    }

    private var sublevels: [SublevelDisplay] {
        guard let attributes = xpManager.userXPData?.subLevels.allAttributes() else { return [] }
        return attributes.map { entry in
            SublevelDisplay(
                name: entry.key.capitalizingFirstLetter(),
                shortName: shortSublevelName(entry.key),
                level: entry.value.level,
                xp: entry.value.xp,
                xpNeeded: max(entry.value.xpNeeded, 1)
            )
        }
    }

    private func shortSublevelName(_ raw: String) -> String {
        if raw.lowercased().contains("lower body compound") { return "L-Comp" }
        if raw.lowercased().contains("lower body isolation") { return "L-Iso" }
        if raw.lowercased().contains("upper body compound") { return "U-Comp" }
        if raw.lowercased().contains("upper body isolation") { return "U-Iso" }
        return raw
    }

    private func signedXP(_ value: Int) -> String {
        value >= 0 ? "+\(value) XP" : "\(value) XP"
    }

    private func formattedTimestamp(_ timestamp: String) -> String {
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: timestamp) {
            return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
        }

        let fallback = DateFormatter()
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        if let date = fallback.date(from: timestamp) {
            return date.formatted(.dateTime.month(.abbreviated).day().hour().minute())
        }

        return timestamp
    }

    private func iconName(for keyword: String) -> String {
        switch keyword {
        case "Weight", "Added Weight": return "scalemass.fill"
        case "Rest": return "bed.double.fill"
        case "Endurance": return "flame.fill"
        case "Consistency": return "chart.bar.fill"
        case "Challenge", "Challenge Success": return "trophy.fill"
        case "Program": return "calendar"
        case "Gym Session Completed": return "dumbbell.fill"
        default: return "star.fill"
        }
    }

    private func refreshData() async {
        if levelChangeManager.levelChanges.isEmpty {
            await levelChangeManager.getLevelChanges()
        }

        if trendManager.levelTrend.isEmpty {
            await trendManager.getLevelTrend()
        }

        var points = trendManager.levelTrend.sorted { $0.date < $1.date }

        if let currentLevel = xpManager.userXPData?.level {
            let now = Date()
            if let existingIndex = points.lastIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: now) }) {
                points[existingIndex] = HealthDataPoint(date: now, value: Double(currentLevel))
            } else {
                points.append(HealthDataPoint(date: now, value: Double(currentLevel)))
            }
        }

        levelTrendPoints = points.sorted { $0.date < $1.date }
    }
}

private struct DashboardSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)

            content
        }
        .padding(16)
        .engineeredPanel(isElevated: false)
    }
}

private struct SublevelDisplay: Identifiable {
    let id = UUID()
    let name: String
    let shortName: String
    let level: Int
    let xp: Int
    let xpNeeded: Int

    var completion: Double {
        min(max(Double(xp) / Double(max(xpNeeded, 1)), 0), 1)
    }
}

private struct SublevelCard: View {
    let sublevel: SublevelDisplay

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(sublevel.name)
                .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .lineLimit(2)

            Text("Level \(sublevel.level)")
                .font(AppTheme.Typography.monumentalNumber(size: 16))
                .foregroundColor(AppTheme.Colors.bluePrimary)
                .controlledGlow(isActive: true, color: AppTheme.Colors.bluePrimary.opacity(0.3))

            ProgressView(value: sublevel.completion)
                .progressViewStyle(.linear)
                .tint(AppTheme.Colors.bluePrimary)
                .background(Color.white.opacity(0.1))

            Text("\(sublevel.xp)/\(sublevel.xpNeeded) XP")
                .font(AppTheme.Typography.monumentalNumber(size: 11))
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.Colors.surfaceLight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous)
                .stroke(Color.white.opacity(0.04), lineWidth: 1)
        )
    }
}

#Preview {
    FullLevelBreakdownView()
}
