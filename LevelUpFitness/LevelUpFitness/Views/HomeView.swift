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
    
    @State var avPlayer = AVPlayer()
    
    @State var days: [String: String] = ["5/20" : "Happy", "5/21" : "Happy", "5/22" : "Happy", "5/23" : "Happy", "5/24" : "Happy", "5/25" : "Happy", "5/26" : "Happy"]
    
    @Binding var pageType: PageType
    
    @State private var contentSize: CGSize = .zero
    
    @State private var showFullLevelBreakdownView: Bool = false
    @State private var showLevelUpInformationView: Bool = false
    
    @State var selectedExercise: Progression?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240 / 255.0, green: 244 / 255.0, blue: 252 / 255.0)
                    .ignoresSafeArea(.all)
                
                ScrollView(.vertical) {
                    
                    VStack (spacing: 0){
                        HStack {
                            Text("Hello Shriram")
                                .font(.custom("EtruscoNow Medium", size: 30))
                                .bold()
                            
                            Spacer()
                            
                            Circle()
                                .frame(width: UIScreen.main.bounds.width / 16, height: UIScreen.main.bounds.width / 16)
                                .overlay(
                                    Image("Headshot")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width / 16, height: UIScreen.main.bounds.width / 16)
                                        .clipShape(Circle())
                                )
                            
                            Circle()
                                .fill(.gray.opacity(0.15))
                                .frame(width: UIScreen.main.bounds.width / 16, height: UIScreen.main.bounds.width / 16)
                            
                                .overlay (
                                    Image(systemName: "bell")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipped()
                                        .padding(5)
                                        
                                )
                        }
                        .padding(.horizontal)
                        
                        VStack (spacing: 20) {
                            if let userXPData = xpManager.userXPData {
                                LevelWidget(userXPData: userXPData, levelChanges: xpManager.levelChanges, openFullBreakdownView: {
                                    showFullLevelBreakdownView = true
                                }, openLevelUpInfoView: {
                                    showLevelUpInformationView = true
                                })
                            }
                            else {
                                LevelWidget(userXPData: XPData(userID: "", level: 0, xp: 0, xpNeeded: 15, subLevels: Sublevels(lowerBodyCompound: XPAttribute(xp: 0, level: 0, xpNeeded: 0), lowerBodyIsolation: XPAttribute(xp: 0, level: 0, xpNeeded: 0), upperBodyCompound: XPAttribute(xp: 0, level: 0, xpNeeded: 0), upperBodyIsolation: XPAttribute(xp: 0, level: 0, xpNeeded: 0))), levelChanges: [], openFullBreakdownView: {
                                    showFullLevelBreakdownView = true
                                }, openLevelUpInfoView: {
                                    showLevelUpInformationView = true
                                })
                            }
                            
                            ScrollView (.horizontal) {
                                HStack {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 47 / 255, green: 196 / 255, blue: 298 / 255),
                                                    Color(red: 17 / 255, green: 150 / 255, blue: 238 / 255)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay (
                                            VStack {
                                                Spacer()
                                                
                                                Image("ManRunning")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                
                                                Text("Exercise Now")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                
                                                Button(action: {
                                                    pageType = .library
                                                }, label: {
                                                    Text("Start")
                                                        .font(.headline)
                                                        .foregroundColor(.blue)
                                                        .frame(minWidth: 0, maxWidth: .infinity)
                                                        .padding()
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 5)
                                                                .fill(.white)
                                                        )
                                                })
                                            }
                                                .padding()
                                        )
                                        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 3.5)
                                    
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color(red: 152/255, green: 230/255, blue: 138/255),
                                                    Color(red: 17 / 255, green: 150 / 255, blue: 238 / 255)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .overlay (
                                            VStack {
                                                Spacer()
                                                
                                                Image("ManExercising - PushUp - No BG")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                
                                                Text("Do your Program")
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                                    .multilineTextAlignment(.center)
                                                
                                                Button {
                                                    pageType = .program
                                                } label: {
                                                    Text("Start")
                                                        .font(.headline)
                                                        .foregroundColor(.blue)
                                                        .frame(minWidth: 0, maxWidth: .infinity)
                                                        .padding()
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 5)
                                                                .fill(.white)
                                                        )
                                                }

                                            }
                                                .padding()
                                        )
                                        .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 3.5)
                                }
                                
                            }
                 
                        }
                        .scrollIndicators(.hidden)
                        .padding([.top, .horizontal])
                         
                        if let recommendedExercise = exerciseManager.recommendedExercise {
                            RecommendedExerciseWidget(exercise: recommendedExercise, exerciseSelected: {
                                self.selectedExercise = recommendedExercise
                            })
                            .padding()
                        }
                        
                        
                        if challengeManager.userChallenges.count > 0 {
                            HStack {
                                Text("Your Challenges")
                                    .font(.custom("EtruscoNow Medium", size: 23))
                                    .bold()
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ForEach(challengeManager.userChallenges, id: \.id) { challenge in
                                if let currentProgress = getCurrentChallengeProgress(challengeField: challenge.field) {
                                    ActiveUserChallengeWidget(challenge: challenge, currentProgress: currentProgress)
                                }
                            }
                        }
                        if let program = programManager.program {
                            TimeSpentWidget(program: program)
                                .padding([.top, .horizontal])
                        }
                        
                        if let steps = healthManager.todaysSteps, let calories = healthManager.todaysCalories, let distance = (healthManager.todaysDistance)  {
                            HStack {
                                Text("Today's Health Breakdown")
                                    .font(.custom("EtruscoNow Medium", size: 25))
                                    .bold()
                                
                                Spacer()
                            }
                            .padding(.top)
                            .padding(.horizontal)
                            
                            HealthStatsWidget(stat1: steps, text1: "Steps", imageName1: "figure.walk", stat2: calories, text2: "Calories", imageName2: "flame.fill", stat3: distance, text3: "Distance", imageName3: "app.connected.to.app.below.fill")
                        }
                        
                        if let userXPData = xpManager.userXPData, challengeManager.challengeTemplates.filter({ challengeTemplate in
                            !challengeManager.userChallenges.contains { userChallenge in
                                userChallenge.challengeTemplateID == challengeTemplate.id
                            }
                        }).count > 0 {
                            HStack {
                                Text("Available Challenges")
                                    .font(.custom("EtruscoNow Medium", size: 23))
                                    .bold()
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            ForEach(challengeManager.challengeTemplates.filter { challengeTemplate in
                                !challengeManager.userChallenges.contains { userChallenge in
                                    userChallenge.challengeTemplateID == challengeTemplate.id
                                }
                            }, id: \.id) { challengeTemplate in
                                ChallengeTemplateWidget(challenge: challengeTemplate) {
                                    Task {
                                        await challengeManager.createChallenge(challengeName: challengeTemplate.name, challengeTemplateID: challengeTemplate.id, userXPData: userXPData)
                                    }
                                }
                                .padding()
                            }
                        }


                        VStack (spacing: 10) {
                            HStack {
                                
                                
                                Spacer()
                            }
                            
                            Divider()
                            
                            
                        }
                        .padding()

                        VStack (spacing: 0) {
                            HStack {
                                VStack (alignment: .leading) {
                                    Text("Trends")
                                        .font(.custom("Sailec Bold", size: 20))
                                    
                                    Text("Your Progress")
                                        .foregroundColor(.gray)
                                        .bold()
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 7)

                            GeometryReader { geometry in
                                let totalWidth = geometry.size.width
                                let padding: CGFloat = 10
                                let squareWidth = (totalWidth - padding) / 2
                                
                                HStack(spacing: padding) {
                                    StatisticsWidget(width: squareWidth, colorA: Color(red: 152/255, green: 230/255, blue: 138/255), colorB: .green, stat: 180.5, text: "Current Weight")
                                }
                            }
                            .frame(height: (UIScreen.main.bounds.width - 10) / 2)
                            .padding(.horizontal)
                        }

                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $showFullLevelBreakdownView) {
                if let userXPData = xpManager.userXPData {
                    FullLevelBreakdownView(userXPData: userXPData)
                }
            }
            .fullScreenCover(isPresented: $showLevelUpInformationView, content: {
                LevelInfoView()
            })
            .navigationDestination(item: $selectedExercise) { exercise in
                IndividualExerciseView(progression: exercise)
            }
        }
    }
    
    func getCurrentChallengeProgress(challengeField: String) -> Int? {
        switch challengeField {
            case "Level":
                if let userXPData = xpManager.userXPData {
                    return userXPData.level
                } else {
                    return nil
                }
            default:
                return nil
        }
    }
    
}

#Preview {
    HomeView(programManager: ProgramManager(), databaseManager: DatabaseManager(), healthManager: HealthManager(), xpManager: XPManager(), exerciseManager: ExerciseManager(), challengeManager: ChallengeManager(), pageType: .constant(.home))
}
