//
//  GymSessionView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/22/24.
//

import SwiftUI


struct GymSessionsView: View {
    @ObservedObject var gymManager = GymManager.shared
    @EnvironmentObject private var storeKitManager: StoreKitManager

    @State private var showEndSessionConfirmation = false
    @State private var navigateToExerciseView = false
    @State private var navigateToPastSessionDetailView = false
    @State private var navigateToAddExerciseView = false
    @State private var navigateToAllPastSessionsView = false
    @State private var selectedExerciseRecord: ExerciseRecord?
    @State private var selectedPastSession: GymSession?

    @State var showGymSessionInfoSheet: Bool = false
    @State private var expandedExercises: Set<UUID> = []
    @State private var showPaywall = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerView

                    if let currentSession = gymManager.currentSession {
                        activeGymSessionView(currentSession)
                    } else {
                        startNewSessionView

                        if let mostRecentSession = gymManager.gymSessions.first {
                            recentSessionSummary(for: mostRecentSession)
                        }
                    }

                    pastSessionsView

                    if !gymManager.gymSessions.isEmpty {
                        gymStatsView
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }

            if showEndSessionConfirmation {
                EndSessionConfirmationView(isOpen: $showEndSessionConfirmation, confirmed: {
                    gymManager.endGymSession()
                })
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: showEndSessionConfirmation)
            }
        }
        .navigationDestination(isPresented: $navigateToExerciseView) {
            if let exerciseRecord = selectedExerciseRecord {
                GymSessionExerciseView(exerciseRecord: exerciseRecord)
            }
        }
        .navigationDestination(isPresented: $navigateToPastSessionDetailView) {
            if let pastSession = selectedPastSession {
                PastGymSessionDetailView(session: pastSession)
            }
        }
        .navigationDestination(isPresented: $navigateToAddExerciseView) {
            AddExerciseView(onAddExercise: { exerciseRecord in
                gymManager.currentSession?.addIndividualExercise(exerciseRecord: exerciseRecord)
            })
        }
        .navigationDestination(isPresented: $navigateToAllPastSessionsView) {
            AllPastGymSessionsView(gymManager: gymManager)
        }
        .sheet(isPresented: $showGymSessionInfoSheet, content: {
            GymSessionInfoView()
        })
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(allowDismissal: true) {
                showPaywall = false
            }
            .environmentObject(storeKitManager)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Gym Sessions")
                        .font(.system(size: 30, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)

                    Text(gymManager.currentSession == nil ? "Track every rep, revisit every win." : "Session in progress — keep the momentum going!")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.75))
                }

                Spacer()

                Button {
                    showGymSessionInfoSheet = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .accessibilityLabel("Gym session tips")
                }
            }

            HStack(spacing: 12) {
                if gymManager.currentSession != nil {
                    Label("Active session", systemImage: "dot.radiowaves.left.and.right")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.white.opacity(0.25))
                        .clipShape(Capsule())
                        .foregroundColor(.white)
                }

                Label("\(gymManager.gymSessions.count) logged", systemImage: "calendar")
                    .font(.system(size: 13, weight: .medium))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            LinearGradient(colors: [Color(hex: "3080FF"), Color(hex: "40C4FC")], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 12)
    }

    private var startNewSessionView: some View {
        VStack(alignment: .leading, spacing: 18) {
            Label("Ready for your next workout?", systemImage: "figure.strengthtraining.traditional")
                .font(.system(size: 20, weight: .semibold))

            Text("Start a fresh session to log sets, weights, and rest times in real time.")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                Label("Capture program and custom exercises in one place", systemImage: "rectangle.and.pencil.and.ellipsis")
                Label("Get instant volume, set, and rest analytics", systemImage: "chart.bar")
                Label("Save sessions automatically when you finish", systemImage: "externaldrive")
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.secondary)

            Button {
                gymManager.startGymSession()
            } label: {
                HStack {
                    Spacer()
                    Label("Start new session", systemImage: "play.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(cardBackground())
    }


    private func activeGymSessionView(_ currentSession: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Active session")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(gymManager.elapsedTime)
                        .font(.system(size: 36, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "3080FF"))
                }

                Spacer()

                Button {
                    showEndSessionConfirmation = true
                } label: {
                    Label("End", systemImage: "stop.circle")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 18)
                        .background(Color(hex: "FF3B30"))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            sessionMetricScroll(for: currentSession, elapsedTime: gymManager.elapsedTime)

            highlightView(for: currentSession, context: .interactive)

            exercisesListView(currentSession)

            Button {
                navigateToAddExerciseView = true
            } label: {
                HStack {
                    Spacer()
                    Label("Add exercise", systemImage: "plus.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(
                    LinearGradient(colors: [Color(hex: "3080FF"), Color(hex: "40C4FC")], startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(cardBackground())
    }


    @ViewBuilder
    private func recentSessionSummary(for session: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Latest session recap")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Text(session.startTime, style: .date)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            sessionMetricGrid(for: session, elapsedTime: formattedDuration(for: session))

            highlightView(for: session, context: .informational)
        }
        .padding(24)
        .background(cardBackground())
    }

    private func sessionMetricScroll(for session: GymSession, elapsedTime: String? = nil) -> some View {
        let metrics = sessionMetrics(for: session, elapsedTime: elapsedTime)
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(metrics) { metric in
                    SessionMetricChip(metric: metric, isProminent: true)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func sessionMetricGrid(for session: GymSession, elapsedTime: String? = nil) -> some View {
        let metrics = sessionMetrics(for: session, elapsedTime: elapsedTime)
        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(metrics) { metric in
                SessionMetricChip(metric: metric, isProminent: false)
            }
        }
    }

    private func sessionMetrics(for session: GymSession, elapsedTime: String?) -> [SessionMetric] {
        var metrics: [SessionMetric] = [
            SessionMetric(title: "Exercises", value: "\(session.totalExercisesCount)", iconName: "figure.strengthtraining.traditional"),
            SessionMetric(title: "Sets", value: "\(session.totalSets)", iconName: "list.number"),
            SessionMetric(title: "Reps", value: "\(session.totalReps)", iconName: "repeat"),
            SessionMetric(title: "Volume", value: formatVolume(session.totalVolume), iconName: "scalemass")
        ]

        if let rest = session.averageRestSeconds {
            metrics.append(SessionMetric(title: "Avg rest", value: formatRest(seconds: rest), iconName: "hourglass"))
        }

        if let elapsedTime {
            metrics.insert(SessionMetric(title: "Elapsed", value: elapsedTime, iconName: "stopwatch"), at: 0)
        } else if let duration = session.duration {
            metrics.insert(SessionMetric(title: "Duration", value: formatDuration(duration), iconName: "clock"), at: 0)
        }

        return metrics
    }

    @ViewBuilder
    private func highlightView(for session: GymSession, context: HighlightContext) -> some View {
        if let highlight = session.highlightLift {

        let content = HStack(spacing: 16) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 22))
                .foregroundColor(Color(hex: "3080FF"))
                .padding(12)
                .background(Color(hex: "3080FF").opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(context == .interactive ? "Heaviest lift so far" : "Session highlight")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)

                Text(highlight.exerciseName)
                    .font(.system(size: 17, weight: .semibold))

                Text("\(highlight.set.reps) reps at \(formatWeight(highlight.set.weight))")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if context == .interactive {
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "3080FF"))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )

        switch context {
        case .interactive:
            if let record = exerciseRecord(for: highlight, in: session) {
                Button {
                    selectedExerciseRecord = record
                    navigateToExerciseView = true
                } label: {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        case .informational:
            content
        }
        } else {
            EmptyView()
        }
    }

    private func exerciseRecord(for highlight: (exerciseName: String, set: ExerciseDataSet), in session: GymSession) -> ExerciseRecord? {
        session.loggedExercises.first { record in
            record.exerciseInfo.exerciseName == highlight.exerciseName && record.heaviestSet == highlight.set
        } ?? session.loggedExercises.first { $0.exerciseInfo.exerciseName == highlight.exerciseName }
    }

    private func formattedDuration(for session: GymSession) -> String? {
        guard let duration = session.duration else { return nil }
        return formatDuration(duration)
    }

    private func cardBackground() -> some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(Color(uiColor: .systemBackground))
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 12)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%dhr %02dmin", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dmin %02ds", minutes, seconds)
        } else {
            return String(format: "%02ds", seconds)
        }
    }

    private func formatRest(seconds: Double) -> String {
        let intSeconds = Int(seconds.rounded())
        let minutes = intSeconds / 60
        let remainingSeconds = intSeconds % 60

        if minutes > 0 {
            return String(format: "%dm %02ds", minutes, remainingSeconds)
        } else {
            return String(format: "%02ds", remainingSeconds)
        }
    }

    private func formatWeight(_ weight: Int) -> String {
        "\(weight) lb" + (weight == 1 ? "" : "s")
    }

    private func formatVolume(_ value: Double) -> String {
        let pounds = Int(value.rounded())
        if pounds >= 1000 {
            return String(format: "%.1fk lbs", Double(pounds) / 1000.0)
        } else {
            return "\(pounds) lbs"
        }
    }

    private enum HighlightContext {
        case interactive
        case informational
    }


    private func exercisesListView(_ currentSession: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Logged exercises")
                .font(.system(size: 18, weight: .semibold))

            if currentSession.loggedExercises.isEmpty {
                Text("Your sets will appear here as soon as you add them.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
            } else {
                if !currentSession.programExercises.isEmpty {
                    ForEach(currentSession.programExercises.keys.sorted(), id: \.self) { programName in
                        if let records = currentSession.programExercises[programName] {
                            exerciseSection(title: programName, records: records)
                        }
                    }
                }

                if !currentSession.individualExercises.isEmpty {
                    exerciseSection(title: "Personal adds", records: currentSession.individualExercises)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    private func exerciseSection(title: String, records: [ExerciseRecord]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 4)

            ForEach(records) { record in
                exerciseRow(for: record)
            }
        }
    }

    private func exerciseRow(for record: ExerciseRecord) -> some View {
        let isExpanded = binding(for: record)
        let bestSet = record.heaviestSet

        return DisclosureGroup(isExpanded: isExpanded) {
            Divider()
                .padding(.vertical, 8)

            setDetailRows(for: record)

            Button {
                selectedExerciseRecord = record
                navigateToExerciseView = true
            } label: {
                Label("View detailed log", systemImage: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .buttonStyle(.borderless)
            .padding(.top, 4)
        } label: {
            HStack(alignment: .center, spacing: 16) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        LinearGradient(colors: [Color(hex: "3080FF"), Color(hex: "40C4FC")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(record.exerciseInfo.exerciseName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    HStack(spacing: 8) {
                        metricTag(icon: "number", text: "\(record.totalSets) sets")
                        metricTag(icon: "repeat", text: "\(record.totalReps) reps")
                        if let bestSet {
                            metricTag(icon: "scalemass", text: formatWeight(bestSet.weight))
                        }
                    }
                }

                Spacer()

                Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 12)
        }
        .accentColor(.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
        )
    }

    private func binding(for record: ExerciseRecord) -> Binding<Bool> {
        Binding<Bool>(
            get: { expandedExercises.contains(record.id) },
            set: { isExpanded in
                if isExpanded {
                    expandedExercises.insert(record.id)
                } else {
                    expandedExercises.remove(record.id)
                }
            }
        )
    }

    private func setDetailRows(for record: ExerciseRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(record.exerciseData.sets.enumerated()), id: \.offset) { index, set in
                setDetailRow(index: index, set: set)
            }
        }
    }

    private func setDetailRow(index: Int, set: ExerciseDataSet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Set \(index + 1)")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Text("\(set.reps) reps")
                    .font(.system(size: 15, weight: .semibold))
            }

            HStack(spacing: 8) {
                if set.weight > 0 {
                    metricTag(icon: "scalemass", text: formatWeight(set.weight))
                }
                if set.time > 0 {
                    metricTag(icon: "stopwatch", text: formatRest(seconds: set.time))
                }
                if set.rest > 0 {
                    metricTag(icon: "hourglass", text: formatRest(seconds: set.rest))
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func metricTag(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
            Text(text)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(Color(hex: "3080FF"))
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color(hex: "3080FF").opacity(0.12))
        .clipShape(Capsule())
    }

    private var pastSessionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Past sessions")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Button {
                    if storeKitManager.effectiveIsPremiumUnlocked {
                        navigateToAllPastSessionsView = true
                    } else {
                        storeKitManager.recordPaywallTrigger(.premiumHistory)
                        showPaywall = true
                    }
                } label: {
                    Label("See all", systemImage: "chevron.right")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "3080FF"))
                }
                .buttonStyle(.plain)
            }

            if gymManager.gymSessions.isEmpty {
                Text("Complete a workout to start building your history.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.secondary)
            } else {
                ForEach(gymManager.loadAllGymSessions().prefix(3)) { session in
                    Button {
                        selectedPastSession = session
                        navigateToPastSessionDetailView = true
                    } label: {
                        sessionHistoryCard(for: session)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .background(cardBackground())
    }

    private var gymStatsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My trends")
                .font(.system(size: 20, weight: .semibold))

            if storeKitManager.effectiveIsPremiumUnlocked {
                if gymManager.gymSessions.totalNumberOfSessions >= 2 {
                    GymSessionsStatsView()
                } else {
                    Text("Trends will appear once 2 sessions have been completed")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                }
            } else {
                premiumUpsellCard
            }
        }
        .padding(24)
        .background(cardBackground())
    }

    private var premiumUpsellCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Premium analytics", systemImage: "sparkles")
                .font(.system(size: 18, weight: .semibold))

            Text("Unlock trends for volume, rest, top sets, and more with LevelUp Premium.")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)

            Button {
                storeKitManager.recordPaywallTrigger(.premiumAnalytics)
                showPaywall = true
            } label: {
                Text("See what's included")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(hex: "3080FF"))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(hex: "E8F3FF"))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func sessionHistoryCard(for session: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.startTime, style: .date)
                        .font(.system(size: 17, weight: .semibold))

                    Text(session.startTime, style: .time)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            sessionMetricGrid(for: session, elapsedTime: formattedDuration(for: session))

            highlightView(for: session, context: .informational)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        )
    }

}

struct SessionMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let iconName: String
}

struct SessionMetricChip: View {
    let metric: SessionMetric
    var isProminent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: metric.iconName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hex: "3080FF"))
                    .frame(width: 16, height: 16)

                Text(metric.title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            Text(metric.value)
                .font(isProminent ? .system(size: 20, weight: .bold) : .system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.vertical, isProminent ? 14 : 12)
        .padding(.horizontal, isProminent ? 16 : 14)
        .frame(minWidth: isProminent ? 140 : nil, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isProminent ? Color(uiColor: .systemBackground) : Color(uiColor: .secondarySystemGroupedBackground))
        )
        .shadow(color: isProminent ? Color.black.opacity(0.08) : Color.clear, radius: 10, x: 0, y: 6)
    }
}

struct GymSessionExerciseView: View {
    let exerciseRecord: ExerciseRecord

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                exerciseHeader

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                    ForEach(exerciseMetrics) { metric in
                        SessionMetricChip(metric: metric, isProminent: false)
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Logged sets")
                        .font(.system(size: 18, weight: .semibold))

                    ForEach(Array(exerciseRecord.exerciseData.sets.enumerated()), id: \.offset) { index, set in
                        setCard(for: set, index: index)
                    }
                }
            }
            .padding(24)
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(exerciseTitle)
    }

    private var exerciseHeader: some View {
        HStack(alignment: .center, spacing: 18) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 28))
                .foregroundColor(.white)
                .padding(22)
                .background(
                    LinearGradient(colors: [Color(hex: "3080FF"), Color(hex: "40C4FC")], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(exerciseTitle)
                    .font(.system(size: 26, weight: .bold))

                Text("\(exerciseRecord.totalSets) sets • \(exerciseRecord.totalReps) reps")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
    }

    private var exerciseMetrics: [SessionMetric] {
        var metrics: [SessionMetric] = [
            SessionMetric(title: "Sets", value: "\(exerciseRecord.totalSets)", iconName: "list.number"),
            SessionMetric(title: "Reps", value: "\(exerciseRecord.totalReps)", iconName: "repeat"),
            SessionMetric(title: "Volume", value: formatVolume(exerciseRecord.totalVolume), iconName: "scalemass")
        ]

        if let bestSet = exerciseRecord.heaviestSet, bestSet.weight > 0 {
            metrics.append(SessionMetric(title: "Top set", value: "\(bestSet.reps) x \(bestSet.weight) lb", iconName: "star.fill"))
        }

        if let rest = exerciseRecord.averageRestSeconds {
            metrics.append(SessionMetric(title: "Avg rest", value: formatRest(rest), iconName: "hourglass"))
        }

        return metrics
    }

    private func setCard(for set: ExerciseDataSet, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Set \(index + 1)")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Text("\(set.reps) reps")
                    .font(.system(size: 16, weight: .semibold))
            }

            HStack(spacing: 10) {
                if set.weight > 0 {
                    chip(icon: "scalemass", text: "\(set.weight) lb")
                }
                if set.time > 0 {
                    chip(icon: "stopwatch", text: formatRest(set.time))
                }
                if set.rest > 0 {
                    chip(icon: "hourglass", text: formatRest(set.rest))
                }
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
        )
    }

    private func chip(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(Color(hex: "3080FF"))
        .padding(.vertical, 6)
        .padding(.horizontal, 10)
        .background(Color(hex: "3080FF").opacity(0.12))
        .clipShape(Capsule())
    }

    private var exerciseTitle: String {
        switch exerciseRecord.exerciseInfo {
        case .programExercise(let programExercise):
            return programExercise.name
        case .libraryExercise(let libraryExercise):
            return libraryExercise.name
        }
    }

    private func formatRest(_ seconds: Double) -> String {
        let total = Int(seconds.rounded())
        let minutes = total / 60
        let remaining = total % 60
        if minutes > 0 {
            return "\(minutes)m \(remaining)s"
        } else {
            return "\(remaining)s"
        }
    }

    private func formatVolume(_ value: Double) -> String {
        let pounds = Int(value.rounded())
        if pounds >= 1000 {
            return String(format: "%.1fk lbs", Double(pounds) / 1000.0)
        } else {
            return "\(pounds) lbs"
        }
    }
}


struct EndSessionConfirmationView: View {
    @Binding var isOpen: Bool
    var confirmed: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isOpen = false
                    }
                }
            
            VStack(spacing: 24) {
                Text("End Gym Session")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "333333"))
                
                Text("Are you sure you want to end your gym session?")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "666666"))
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            isOpen = false
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "F5F5F5"))
                    }
                    
                    Button(action: {
                        withAnimation {
                            confirmed()
                            isOpen = false
                        }
                    }) {
                        Text("End Session")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "40C4FC"))
                    }
                }
            }
            .padding()
            .background(Color.white)
            .padding()
        }
    }
}

struct PastGymSessionDetailView: View {
    let session: GymSession
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView (.vertical) {
                VStack(spacing: 16) {
                    HStack {
                        backButton
                        
                        Spacer()
                    }
                    
                    sessionDetailsCard
                    
                    exercisesListView
                        .padding(.top, 8)
                    
                }
                .padding(.horizontal)
                
                VStack (spacing: 6) {
                    HStack {
                        Text("Session Stats")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    GymSessionStatsView(session: session)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Session Details")
                .font(.system(size: 24, weight: .medium, design: .default))
                .foregroundColor(Color(hex: "333333"))
            
            Text("Review your past workout")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(Color(hex: "666666"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var sessionDetailsCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Gym Session")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "333333"))
                    
                    Text(session.startTime, style: .date)
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(Color(hex: "666666"))
                }
                
                Spacer()
                
                Image(systemName: "clock")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
            }
            
            Divider()
            
            HStack {
                timeInfoView(title: "Start", time: session.startTime)
                Spacer()
                timeInfoView(title: "End", time: session.endTime ?? Date())
            }
            
            HStack {
                infoView(title: "Duration", value: String(format: "%.1f mins", (session.duration ?? 0.0) / 60))
                Spacer()
                infoView(title: "Exercises", value: "\(session.programExercises.flatMap { $0.value }.count + session.individualExercises.count)")
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
    
    private func timeInfoView(title: String, time: Date) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(hex: "666666"))
            Text(time, style: .time)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "333333"))
        }
    }
    
    private func infoView(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(Color(hex: "666666"))
            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "333333"))
        }
    }
    
    private var exercisesListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Completed Exercises")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            ForEach(session.programExercises.flatMap { $0.value } + session.individualExercises) { exerciseRecord in
                exerciseWidget(for: exerciseRecord)
            }
        }
//        .background(Color(hex: "F5F5F5"))
    }
    
    private func exerciseWidget(for exerciseRecord: ExerciseRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 16) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "3080FF")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    switch exerciseRecord.exerciseInfo {
                        case .programExercise(let programExercise):
                            Text(programExercise.name)
                                .font(.system(size: 18, weight: .medium))
                        case .libraryExercise(let libraryExercise):
                            Text(libraryExercise.name)
                                .font(.system(size: 18, weight: .medium))
                    }

                    Text("\(exerciseRecord.exerciseData.sets.count) sets")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Color(hex: "666666"))
                }

                Spacer()
            }
            
            ForEach(Array(exerciseRecord.exerciseData.sets.enumerated()), id: \.offset) { index, set in
                HStack {
                    Text("Set \(index + 1)")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(Color(hex: "666666"))
                    Spacer()
                    Text("\(set.reps) reps • \(set.weight) lbs")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "333333"))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
    
    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(hex: "40C4FC"))
                .frame(width: 40, height: 40)
        }
    }
}

struct AllPastGymSessionsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var storeKitManager: StoreKitManager

    @ObservedObject var gymManager: GymManager
    @State private var navigateToPastSessionDetailView = false
    @State private var selectedPastSession: GymSession?
    @State private var showPaywall = false

    var body: some View {
        Group {
            if storeKitManager.effectiveIsPremiumUnlocked {
                ScrollView {
                    VStack(spacing: 20) {
                        header

                        ForEach(gymManager.loadAllGymSessions()) { session in
                            Button {
                                selectedPastSession = session
                                navigateToPastSessionDetailView = true
                            } label: {
                                sessionCard(for: session)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(24)
                }
            } else {
                VStack(spacing: 24) {
                    header

                    Image(systemName: "lock.rectangle.stack")
                        .font(.system(size: 48))
                        .foregroundColor(Color(hex: "3080FF"))

                    Text("Full history is a Premium feature")
                        .font(.title3.weight(.semibold))

                    Text("Upgrade to keep every workout at your fingertips and unlock advanced trends.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button {
                        storeKitManager.recordPaywallTrigger(.premiumHistory)
                        showPaywall = true
                    } label: {
                        Text("Upgrade to Premium")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color(hex: "3080FF"))
                            .clipShape(Capsule())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(24)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground).ignoresSafeArea())
        .navigationDestination(isPresented: $navigateToPastSessionDetailView) {
            if let pastSession = selectedPastSession {
                PastGymSessionDetailView(session: pastSession)
            }
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(allowDismissal: true) {
                showPaywall = false
            }
            .environmentObject(storeKitManager)
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "3080FF"))
                    .padding(10)
                    .background(Color(hex: "3080FF").opacity(0.1))
                    .clipShape(Circle())
            }

            Spacer()

            Text("Past sessions")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)

            Spacer()

            Spacer()
                .frame(width: 44)
        }
    }

    private func sessionCard(for session: GymSession) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.startTime, style: .date)
                        .font(.system(size: 18, weight: .semibold))

                    Text(session.startTime, style: .time)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(sessionMetricData(for: session)) { metric in
                    SessionMetricChip(metric: metric, isProminent: false)
                }
            }

            if let highlight = session.highlightLift {
                highlightRow(for: highlight)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }

    private func sessionMetricData(for session: GymSession) -> [SessionMetric] {
        var metrics: [SessionMetric] = [
            SessionMetric(title: "Exercises", value: "\(session.totalExercisesCount)", iconName: "figure.strengthtraining.traditional"),
            SessionMetric(title: "Sets", value: "\(session.totalSets)", iconName: "list.number"),
            SessionMetric(title: "Reps", value: "\(session.totalReps)", iconName: "repeat"),
            SessionMetric(title: "Volume", value: formatVolume(session.totalVolume), iconName: "scalemass")
        ]

        if let duration = session.duration {
            metrics.insert(SessionMetric(title: "Duration", value: formatDuration(duration), iconName: "clock"), at: 0)
        }

        return metrics
    }

    private func highlightRow(for highlight: (exerciseName: String, set: ExerciseDataSet)) -> some View {
        HStack(spacing: 14) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "3080FF"))
                .padding(12)
                .background(Color(hex: "3080FF").opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Session highlight")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)

                Text(highlight.exerciseName)
                    .font(.system(size: 16, weight: .semibold))

                Text("\(highlight.set.reps) reps @ \(highlight.set.weight) lb")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%dhr %02dmin", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dmin %02ds", minutes, seconds)
        } else {
            return String(format: "%02ds", seconds)
        }
    }

    private func formatVolume(_ value: Double) -> String {
        let pounds = Int(value.rounded())
        if pounds >= 1000 {
            return String(format: "%.1fk lbs", Double(pounds) / 1000.0)
        } else {
            return "\(pounds) lbs"
        }
    }
}

struct AddExerciseView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var exerciseName: String = ""
    @State private var sets: [ExerciseDataSet] = [ExerciseDataSet(weight: 0, reps: 0, time: 0, rest: 0)]
    
    var onAddExercise: (ExerciseRecord) -> Void

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "40C4FC"))
                }
                Spacer()
            }
            .padding()

            HStack {
                Text("Add Exercise")
                    .font(.system(size: 24, weight: .bold))
                    .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal)

            TextField("Exercise Name", text: $exerciseName)
                .font(.system(size: 18, weight: .medium))
                .padding()
                .background(Color(hex: "F5F5F5"))
//                .cornerRadius(8)
                .padding(.horizontal)

            ScrollView {
                ForEach(sets.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Set \(index + 1)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.black)

                            
                            Spacer()
                            
                            if index == 0 {
                                Button {
                                    sets.append(ExerciseDataSet(weight: 0, reps: 0, time: 0, rest: 0))
                                } label: {
                                    Image(systemName: "plus")
                                        .foregroundColor(.black)
                                        .font(.system(size: 20))
                                        .padding(7)
                                        .background(Circle().fill(Color(hex: "F5F5F5")))
                                }
                            } else {
                                Button {
                                    sets.remove(at: index)
                                } label: {
                                    Image(systemName: "minus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 20))
                                        .padding(7)
                                        .background(Circle().fill(Color.red))
                                }
                            }

                        }
                        inputFieldsView(for: index)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal)
                    Divider()
                }
            }

            Spacer()

            Button(action: {
                let exerciseRecord = ExerciseRecord(
                    exerciseInfo: .libraryExercise(Progression(name: exerciseName, description: "", level: 0, cdnURL: "", exerciseType: "", isWeight: false)),
                    exerciseData: ExerciseData(sets: sets)
                )
                onAddExercise(exerciseRecord)
                dismiss()
            }) {
                Text("Add Exercise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden()
    }

    private func inputFieldsView(for index: Int) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                inputField(title: "Weight", value: $sets[index].weight, unit: "lbs")
                inputField(title: "Reps", value: $sets[index].reps, unit: "reps")
            }

            HStack(spacing: 16) {
                inputField(title: "Time", value: $sets[index].time, unit: "seconds")
                inputField(title: "Rest", value: $sets[index].rest, unit: "seconds")
            }
        }
    }

    private func inputField(title: String, value: Binding<Int>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.secondary)
            HStack {
                TextField("0", value: value, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .font(.system(size: 18, weight: .medium))
                Text(unit)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
    }

    private func inputField(title: String, value: Binding<Double>, unit: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.secondary)
            HStack {
                TextField("0", value: value, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .font(.system(size: 18, weight: .medium))
                Text(unit)
                    .font(.system(size: 14, weight: .light))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

struct GymSessionInfoView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color(hex: "CCCCCC"))
                }
                .padding()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Mastering gym sessions")
                        .font(.system(size: 30, weight: .bold))
                        .padding(.horizontal)

                    infoCard(title: "Live logging", description: "Start a session to unlock the real‑time timer, quick add button, and detailed exercise rows. Every set you record feeds session metrics like volume, reps, and average rest automatically.") {
                        Label("Tap \"Add exercise\" to capture custom lifts on the fly", systemImage: "plus.circle")
                        Label("Program workouts appear the moment you complete them", systemImage: "list.bullet.rectangle")
                        Label("Session highlights surface your heaviest set for fast review", systemImage: "trophy")
                    }

                    infoCard(title: "Session analytics", description: "Scroll to \"My trends\" after logging a few workouts to see total volume, reps, and weekly momentum. Premium unlocks charts for volume, rest, and streaks so you can spot patterns at a glance.") {
                        Label("Open any past session to view every recorded set", systemImage: "clock.arrow.circlepath")
                        Label("Upgrade to Premium to compare volume, reps, and rest trends over time", systemImage: "chart.xyaxis.line")
                        Label("Use the highlight badge to jump directly to your strongest lifts", systemImage: "sparkles")
                    }

                    infoCard(title: "Adding new plans", description: "Programs control the workouts that auto-populate inside gym sessions. Follow these steps to join or create a new plan:") {
                        Label("Navigate to the Programs tab from the main navigation bar", systemImage: "square.grid.2x2")
                        Label("Tap the program title at the top and choose \"View Programs\" to browse", systemImage: "magnifyingglass")
                        Label("Join a standard plan or tap \"Request a custom plan\" to submit your preferences", systemImage: "person.crop.circle.badge.plus")
                        Label("Look for the Premium badge — those plans require an active subscription to unlock", systemImage: "star.circle.fill")
                        Label("Once joined, the day's workout will appear automatically in the active session list", systemImage: "bolt.badge.clock")
                    }

                    infoCard(title: "Finishing strong", description: "End a session when your final set is logged. We’ll save the workout, update your trends, and award the appropriate XP.") {
                        Label("Review the recap screen for time, sets, and highlight lifts", systemImage: "chart.bar.doc.horizontal")
                        Label("Use the history button on the Gym Sessions screen to revisit any logged day", systemImage: "clock")
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    private func infoCard(title: String, description: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))

            Text(description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 10, content: content)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "3080FF"))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        )
        .padding(.horizontal)
    }
}

