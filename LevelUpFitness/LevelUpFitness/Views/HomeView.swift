import SwiftUI

struct HomeView: View {
    @ObservedObject var programManager = ProgramManager.shared
    @ObservedObject var healthManager = HealthManager.shared
    @ObservedObject var badgeManager = BadgeManager.shared
    @ObservedObject var xpManager = XPManager.shared
    @ObservedObject var exerciseManager = ExerciseManager.shared
    @ObservedObject var challengeManager = ChallengeManager.shared
    @ObservedObject var levelChangeManager = LevelChangeManager.shared
    @ObservedObject var toDoListManager = ToDoListManager.shared

    @Binding var pageType: PageType

    @State private var showLevelUpInformationView = false
    @State private var selectedExercise: Progression?
    @State private var healthStatType: String = ""
    @State private var navigateToHealthStatTrendView = false
    @State private var navigateToWeightTrendView = false
    @State private var navigateToProfileView = false
    @State private var navigateToAvailableChallengesView = false
    @State private var perfectProgramChallengeStartFailed = false
    @State private var showChallengeDetailsCover = false
    @State private var userChallenge: UserChallenge?
    @State private var showToDoList = true

    var body: some View {
        ZStack {
            Color(hex: "F3F5F8").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 14) {
                    heroHeader
                    quickActionsSection
                    dailyMetricsSection
                    todoSection
                    recommendedSection
                    activeProgramsSection
                    challengeSection
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .alert("Action Failed", isPresented: $perfectProgramChallengeStartFailed) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Unable to start this challenge right now. Complete the required program progress and try again.")
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $navigateToHealthStatTrendView) {
            HealthTrendView(healthStatType: healthStatType)
        }
        .navigationDestination(isPresented: $navigateToProfileView) {
            ProfileView()
        }
        .fullScreenCover(isPresented: $showLevelUpInformationView) {
            LevelInfoView()
        }
        .fullScreenCover(isPresented: $navigateToAvailableChallengesView) {
            ActiveChallengesView()
        }
        .fullScreenCover(isPresented: $navigateToWeightTrendView) {
            WeightTrendView()
        }
        .navigationDestination(item: $selectedExercise) { exercise in
            IndividualExerciseView(progression: exercise)
        }
        .fullScreenCover(isPresented: $showChallengeDetailsCover) {
            if let userChallenge {
                ChallengeDetailsView(
                    challenge: userChallenge,
                    currentProgress: challengeProgress(for: userChallenge)
                )
            }
        }
    }

    private var heroHeader: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(greeting)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    Text(InitializationManager.shared.selectedAffirmation ?? "Stay consistent and keep building.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.85))
                }

                Spacer()

                Button {
                    navigateToProfileView = true
                } label: {
                    profileImage
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                heroStat(
                    title: "Level",
                    value: "\(xpManager.userXPData?.level ?? 1)",
                    actionLabel: "Details",
                    action: { pageType = .levelBreakdown }
                )

                heroStat(
                    title: "Active Programs",
                    value: "\(programManager.userProgramData.count)",
                    actionLabel: "Manage",
                    action: { pageType = .program }
                )

                heroStat(
                    title: "Challenges",
                    value: "\(challengeManager.userChallenges.count)",
                    actionLabel: "Browse",
                    action: { navigateToAvailableChallengesView = true }
                )
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(hex: "0B5ED7"), Color(hex: "1C9BFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private func heroStat(title: String, value: String, actionLabel: String, action: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.82))

            Text(value)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Button(actionLabel, action: action)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var profileImage: some View {
        Group {
            if let pfp = AuthenticationManager.shared.pfp, let uiImage = UIImage(data: pfp) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Image("NoProfile")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.white.opacity(0.7), lineWidth: 1)
        )
    }

    private var quickActionsSection: some View {
        HomeSectionCard(title: "Quick Start", trailing: AnyView(
            Button("Level Guide") { showLevelUpInformationView = true }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
        )) {
            HStack(spacing: 10) {
                HomeActionTile(
                    title: "Program",
                    subtitle: "Continue today's schedule",
                    icon: "figure.strengthtraining.traditional",
                    color: Color(hex: "0B5ED7"),
                    action: { pageType = .program }
                )
                HomeActionTile(
                    title: "Gym",
                    subtitle: "Track a live workout",
                    icon: "dumbbell.fill",
                    color: Color(hex: "1C9BFF"),
                    action: { pageType = .gymSession }
                )
                HomeActionTile(
                    title: "Library",
                    subtitle: "Pick an exercise",
                    icon: "books.vertical.fill",
                    color: Color(hex: "2A7FFF"),
                    action: { pageType = .exercise }
                )
            }
        }
    }

    private var dailyMetricsSection: some View {
        HomeSectionCard(title: "Daily Metrics", trailing: nil) {
            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    if let steps = healthManager.todaysSteps {
                        HealthInsightCard(
                            title: "Steps",
                            value: "\(steps.count)",
                            icon: "figure.walk",
                            comparison: steps.comparison
                        ) {
                            healthStatType = "Steps"
                            navigateToHealthStatTrendView = true
                        }
                    }

                    if let calories = healthManager.todaysCalories {
                        HealthInsightCard(
                            title: "Calories",
                            value: "\(calories.count)",
                            icon: "flame.fill",
                            comparison: calories.comparison
                        ) {
                            healthStatType = "Calories"
                            navigateToHealthStatTrendView = true
                        }
                    }
                }

                Button {
                    navigateToWeightTrendView = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                            .frame(width: 30, height: 30)
                            .background(Color(hex: "E8F3FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text("Weight Trend")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: "111827"))
                            Text("Track weekly changes and momentum")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "6B7280"))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                    }
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var todoSection: some View {
        Group {
            if !toDoListManager.toDoList.isEmpty {
                HomeSectionCard(
                    title: "Today Checklist",
                    trailing: AnyView(
                        Button(showToDoList ? "Hide" : "Show") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showToDoList.toggle()
                            }
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                    )
                ) {
                    if showToDoList {
                        ToDoList(toDoListManager: toDoListManager)
                    } else {
                        Text("Checklist hidden")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "6B7280"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }
                }
            }
        }
    }

    private var recommendedSection: some View {
        Group {
            if let recommendedExercise = exerciseManager.recommendedExercise {
                HomeSectionCard(title: "Recommended Exercise", trailing: nil) {
                    Button {
                        selectedExercise = recommendedExercise
                    } label: {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recommendedExercise.name)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "111827"))

                                Text(recommendedExercise.exerciseType)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(hex: "6B7280"))
                                    .lineLimit(1)
                            }

                            Spacer()

                            Text("Open")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(hex: "0B5ED7"))
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        }
                        .padding(10)
                        .background(Color(hex: "F8FAFC"))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var activeProgramsSection: some View {
        HomeSectionCard(
            title: "Programs In Progress",
            trailing: AnyView(
                Button("Manage") { pageType = .program }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "0B5ED7"))
            )
        ) {
            if programManager.userProgramData.isEmpty {
                Text("No active programs yet. Join one from the Program tab.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            } else {
                ForEach(programManager.userProgramData.prefix(2), id: \.programID) { programWithID in
                    HStack(spacing: 10) {
                        Image(systemName: "list.clipboard.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                            .frame(width: 30, height: 30)
                            .background(Color(hex: "E8F3FF"))
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(programWithID.program.programName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "111827"))
                            Text(programWithID.program.environment)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "6B7280"))
                        }

                        Spacer()

                        Text("Week \(DateUtility.determineWeekNumber(startDateString: programWithID.program.startDate) ?? 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                    }
                    .padding(10)
                    .background(Color(hex: "F8FAFC"))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
        }
    }

    private var challengeSection: some View {
        HomeSectionCard(
            title: "Challenges",
            trailing: AnyView(
                Button("See More") {
                    navigateToAvailableChallengesView = true
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
            )
        ) {
            VStack(spacing: 10) {
                if challengeManager.userChallenges.isEmpty {
                    Text("No active challenges. Start one below.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color(hex: "F8FAFC"))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(challengeManager.userChallenges, id: \.id) { challenge in
                                ChallengeSummaryCard(
                                    title: challenge.name,
                                    progress: challengeProgress(for: challenge),
                                    target: max(challenge.targetValue, 1),
                                    durationText: challengeDurationText(challenge)
                                ) {
                                    userChallenge = challenge
                                    showChallengeDetailsCover = true
                                }
                            }
                        }
                    }
                }

                if let userXPData = xpManager.userXPData, !challengeManager.challengeTemplates.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(availableChallengeTemplates.prefix(2), id: \.id) { template in
                            DiscoverChallengeCard(
                                challenge: template,
                                action: {
                                    Task {
                                        let success = await challengeManager.createChallenge(
                                            challengeName: template.name,
                                            challengeTemplateID: template.id,
                                            userXPData: userXPData
                                        )
                                        if !success {
                                            perfectProgramChallengeStartFailed = true
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
    }

    private var availableChallengeTemplates: [ChallengeTemplate] {
        challengeManager.challengeTemplates.filter { template in
            !challengeManager.userChallenges.contains { $0.challengeTemplateID == template.id }
        }
    }

    private func challengeProgress(for challenge: UserChallenge) -> Int {
        switch challenge.field {
        case "Level":
            return xpManager.userXPData?.level ?? challenge.startValue
        case "ProgramConsistency":
            if let program = programManager.userProgramData.first?.program {
                let result = program.getConsecutiveCompletionDays()
                switch result {
                case .success(let value):
                    return value
                case .failure:
                    return challenge.startValue
                }
            }
            return challenge.startValue
        default:
            return challenge.startValue
        }
    }

    private func challengeDurationText(_ challenge: UserChallenge) -> String {
        "\(formatDate(challenge.startDate)) - \(formatDate(challenge.endDate))"
    }

    private func formatDate(_ value: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: value) {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd"
        if let date = fallbackFormatter.date(from: value) {
            return date.formatted(.dateTime.month(.abbreviated).day())
        }

        return value
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let greetingPrefix: String
        switch hour {
        case 0..<12: greetingPrefix = "Good Morning"
        case 12..<17: greetingPrefix = "Good Afternoon"
        default: greetingPrefix = "Good Evening"
        }
        return "\(greetingPrefix), \(AuthenticationManager.shared.name ?? "there")"
    }
}

private struct HomeSectionCard<Content: View>: View {
    let title: String
    let trailing: AnyView?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                Spacer()
                trailing
            }

            content
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct HomeActionTile: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
                    .frame(width: 30, height: 30)
                    .background(color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))

                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(hex: "F8FAFC"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct HealthInsightCard: View {
    let title: String
    let value: String
    let icon: String
    let comparison: HealthComparison
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                    Spacer()
                    trendBadge
                }

                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "6B7280"))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color(hex: "F8FAFC"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var trendBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: trendIcon)
                .font(.system(size: 10, weight: .bold))
            Text(trendText)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(trendColor)
        .padding(.horizontal, 7)
        .padding(.vertical, 4)
        .background(trendColor.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var trendIcon: String {
        switch comparison {
        case .equal: return "arrow.right"
        case .greater: return "arrow.up"
        case .less: return "arrow.down"
        }
    }

    private var trendText: String {
        switch comparison {
        case .equal: return "Stable"
        case .greater: return "Up"
        case .less: return "Down"
        }
    }

    private var trendColor: Color {
        switch comparison {
        case .equal: return Color(hex: "2563EB")
        case .greater: return Color(hex: "059669")
        case .less: return Color(hex: "DC2626")
        }
    }
}

private struct ChallengeSummaryCard: View {
    let title: String
    let progress: Int
    let target: Int
    let durationText: String
    let action: () -> Void

    private var completion: Double {
        min(max(Double(progress) / Double(max(target, 1)), 0), 1)
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))
                    .lineLimit(2)

                Text(durationText)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))

                ProgressView(value: completion)
                    .progressViewStyle(.linear)
                    .tint(Color(hex: "0B5ED7"))

                HStack {
                    Text("\(progress)/\(target)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                    Spacer()
                    Text("\(Int(completion * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                }
            }
            .frame(width: 190, alignment: .leading)
            .padding(10)
            .background(Color(hex: "F8FAFC"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct DiscoverChallengeCard: View {
    let challenge: ChallengeTemplate
    let action: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "111827"))

                Text(challenge.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .lineLimit(2)
            }

            Spacer()

            Button("Start", action: action)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(hex: "0B5ED7"))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .padding(10)
        .background(Color(hex: "F8FAFC"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    HomeView(pageType: .constant(.home))
}
