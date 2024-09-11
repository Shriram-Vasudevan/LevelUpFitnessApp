import SwiftUI
import Charts
import AVKit


struct HomeView: View {
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var databaseManager: DatabaseManager
    @ObservedObject var healthManager: HealthManager
    @ObservedObject var xpManager: XPManager
    @ObservedObject var exerciseManager: ExerciseManager
    @ObservedObject var challengeManager: ChallengeManager
    @ObservedObject var levelChangeManager: LevelChangeManager
    @ObservedObject var toDoListManager: ToDoListManager

    @State var avPlayer = AVPlayer()
    @Binding var pageType: PageType
    
    @State private var showFullLevelBreakdownView: Bool = false
    @State private var showLevelUpInformationView: Bool = false
    @State var selectedExercise: Progression?
    @State var healthStatType: String = ""
    @State var navigateToHealthStatTrendView: Bool = false
    @State var navigateToWeightTrendView: Bool = false
    @State var navigateToProfileView: Bool = false
    
    @State private var perfectProgramChallengeStartFailed = false
    
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    HStack {
                        if let name = AuthenticationManager.shared.name {
                            Text("Hello, \(name)")
                                .font(.system(size: 28, weight: .medium, design: .default))
                        } else {
                            Text("Hey There!")
                                .font(.system(size: 28, weight: .medium, design: .default))
                        }
                        Spacer()
                        
                        if let pfp = AuthenticationManager.shared.pfp, let uiImage = UIImage(data: pfp) {
                            Button(action: { navigateToProfileView = true }) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            }
                        } else {
                            Button(action: { navigateToProfileView = true }) {
                                Image("NoProfile")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    
                    if toDoListManager.toDoList.count > 0 {
                        ToDoList()
                    }
                    
                    VStack(spacing: 12) {
                        Text("Time to Start Moving!")
                            .font(.system(size: 20, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            actionCard(title: "Exercise Now", imageName: "ManRunning", action: { pageType = .library })
                            actionCard(title: "Do your Program", imageName: "ManExercising - PushUp - No BG", action: { pageType = .program })
                        }
                    }
                    
                    VStack(spacing: 12) {
                        Text("Your Metrics")
                            .font(.system(size: 20, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if let steps = healthManager.todaysSteps, let calories = healthManager.todaysCalories {
                            HStack(spacing: 16) {
                                HealthStatsWidget(stat: steps, text: "Steps", imageName: "figure.walk", healthStatWidgetPressed: { _ in
                                    healthStatType = "Steps"
                                    navigateToHealthStatTrendView = true
                                })
                                
                                HealthStatsWidget(stat: calories, text: "Calories", imageName: "flame.fill", healthStatWidgetPressed: { _ in
                                    healthStatType = "Calories"
                                    navigateToHealthStatTrendView = true
                                })
                            }
                        }
                    }
                    
                    WeightStatView()
                        .onTapGesture { navigateToWeightTrendView = true }
                    
                    if let program = programManager.program {
                        TimeSpentWidget(program: program)
                            .onTapGesture {
                                pageType = .program
                            }
                    }
                    
                    if let recommendedExercise = exerciseManager.recommendedExercise {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Our Pick for You")
                                    .font(.system(size: 20, weight: .medium))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Spacer()
                            }
                            
                            recommendedExerciseView(recommendedExercise)
                        }
                    }
                
                    
                    VStack(spacing: 12) {
                        if challengeManager.userChallenges.count > 0 {
                            Text("My Challenges")
                                .font(.system(size: 20, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(challengeManager.userChallenges, id: \.id) { challenge in
                                       let (progress, error) = getCurrentChallengeProgress(challengeField: challenge.field)
                                        
                                        if let validProgress = progress {
                                            ActiveUserChallengeWidget(challenge: challenge, currentProgress: validProgress)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if let userXPData = xpManager.userXPData, !challengeManager.challengeTemplates.isEmpty {
                            Text("Available Challenges")
                                .font(.system(size: 20, weight: .medium))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ForEach(challengeManager.challengeTemplates.filter { challengeTemplate in
                                !challengeManager.userChallenges.contains { userChallenge in
                                    userChallenge.challengeTemplateID == challengeTemplate.id
                                }
                            }, id: \.id) { challengeTemplate in
                                ChallengeTemplateWidget(challenge: challengeTemplate) {
                                    Task {
                                        let success = await challengeManager.createChallenge(challengeName: challengeTemplate.name, challengeTemplateID: challengeTemplate.id, userXPData: userXPData)
                                        
                                        if !success {
                                            perfectProgramChallengeStartFailed = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .alert("Action Failed", isPresented: $perfectProgramChallengeStartFailed) {
            Button("Cancel", role: .cancel) { }
            Button("Ok", role: .destructive) {
                
            }
        } message: {
            Text("Unable to start challenge as you have not completed all previous day's programs.")
        }
        .navigationBarBackButtonHidden()
        .accentColor(Color(hex: "40C4FC"))
        .fullScreenCover(isPresented: $navigateToHealthStatTrendView) {
            HealthTrendView(healthStatType: healthStatType)
        }
        .navigationDestination(isPresented: $navigateToProfileView) {
            ProfileView()
        }
        .fullScreenCover(isPresented: $showLevelUpInformationView) {
            LevelInfoView()
        }
        .fullScreenCover(isPresented: $navigateToWeightTrendView) {
            WeightTrendView()
        }
        .navigationDestination(item: $selectedExercise) { exercise in
            IndividualExerciseView(progression: exercise)
        }
    }


    
    private func actionCard(title: String, imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
                    .padding(.top)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
        }
    }
    

    
    private func recommendedExerciseView(_ exercise: Progression) -> some View {
        RecommendedExerciseWidget(exercise: exercise, exerciseSelected: {
            self.selectedExercise = exercise
        })
    }

    func getCurrentChallengeProgress(challengeField: String) -> (Int?, Error?) {
        switch challengeField {
        case "Level":
            return (xpManager.userXPData?.level, nil)
        case "ProgramConsistency":
            if let program = ProgramManager.shared.program {
                let result = try? program.getConsecutiveCompletionDays()
                    if result == nil {
                        return (nil, nil)
                    }
                    switch result! {
                    case .success(let value):
                        return (value, nil)
                    case .failure(let error):
                        return (nil, error)
                    }
            }
            return (nil, nil)
        default:
            return (nil, nil)
        }
    }
}

#Preview {
    HomeView(programManager: ProgramManager(), databaseManager: DatabaseManager(), healthManager: HealthManager(), xpManager: XPManager(), exerciseManager: ExerciseManager(), challengeManager: ChallengeManager(), levelChangeManager: LevelChangeManager(), toDoListManager: ToDoListManager(), pageType: .constant(.home))
}
#Preview {
    HomeView(programManager: ProgramManager(), databaseManager: DatabaseManager(), healthManager: HealthManager(), xpManager: XPManager(), exerciseManager: ExerciseManager(), challengeManager: ChallengeManager(), levelChangeManager: LevelChangeManager(), toDoListManager: ToDoListManager(), pageType: .constant(.home))
}
