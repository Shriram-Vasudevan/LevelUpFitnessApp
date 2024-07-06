import SwiftUI
import Charts
import AVKit


struct HomeView: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var databaseManager: DatabaseManager
    @ObservedObject var healthManager: HealthManager
    @ObservedObject var xpManager: XPManager
    
    @State var avPlayer = AVPlayer()
    
    @State var days: [String: String] = ["5/20" : "Happy", "5/21" : "Happy", "5/22" : "Happy", "5/23" : "Happy", "5/24" : "Happy", "5/25" : "Happy", "5/26" : "Happy"]
    
    @Binding var pageType: PageType
    
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.white
            
            ScrollView(.vertical) {
                HStack {
                    Text("Hello Shriram")
                        .font(.custom("EtruscoNow Medium", size: 30))
                        .bold()
                    
                    Spacer()
                    
                    Image(systemName: "bell")
                }
                .padding(.horizontal)
                .padding(.bottom, -10)
                
                VStack () {
                    if let userXPData = xpManager.userXPData {
                        HStack {
                            LevelCircularProgressBar(progress: Double(userXPData.xp / userXPData.xpNeeded), level: userXPData.level)
                                .frame(width: 50, height: 50)
                                .padding(.trailing, 5)
                            
                            VStack(alignment: .leading) {
                                Text("Let's get that Level Up!")
                                    .font(.headline)
                                Text("Here's how you can do that")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 10)
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
                                        
                                        Image("ManExercising - PushUp - No BG")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                        
                                        Text("Complete some Exercises")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                        
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
                                        .padding()
                                )
                                .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 3.5)
                        }
                        
                    }
         
                }
                .scrollIndicators(.hidden)
                .padding([.vertical, .leading])
                 
                
                VStack (spacing: 10) {
                    HStack {
                        
                        
                        Spacer()
                    }
                    
                    Divider()
                    
                    
                }
                .padding()
                

                
//                        VStack(spacing: 0) {
//                            if let url = storageManager.dailyVideo {
//                                VideoPlayer(player: avPlayer)
//                                    .aspectRatio(contentMode: .fill)
//                                    .frame(height: 200)
//                                    .onAppear {
//                                        avPlayer = AVPlayer(url: url)
//                                    }
//                                    .cornerRadius(10)
//                                    .overlay (
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(.black, lineWidth: 2)
//                                    )
//
//                            } else {
//                                Rectangle()
//                                    .fill(.white)
//                                    .stroke(.black, lineWidth: 2)
//                                    .frame(height: 200)
//                                    .overlay (
//                                        Image("GuyAtTheGym")
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fill)
//                                            .padding(.horizontal)
//                                            .clipped()
//                                    )
//                                    .cornerRadius(10)
//                            }
//                        }
//                        .padding()
//                        .padding(.bottom, 5)
//                        .cornerRadius(15)
//
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
                            if let steps = healthManager.todaysSteps {
                                StatisticsWidget(width: squareWidth, colorA: Color(red: 0 / 255, green: 149 / 255, blue: 246 / 255), colorB: Color(red: 0 / 255, green: 0 / 255, blue: 255 / 255), stat: steps, text: "Steps Today")
                            }
                            
                            StatisticsWidget(width: squareWidth, colorA: Color(red: 152/255, green: 230/255, blue: 138/255), colorB: .green, stat: 180.5, text: "Current Weight")
                        }
                    }
                    .frame(height: (UIScreen.main.bounds.width - 10) / 2)
                    .padding(.horizontal)
                }
                
                VStack() {
                    if !days.isEmpty {
                        HStack() {
                            Chart {
                                ForEach(days.keys.sorted(), id: \.self) { date in
                                    let randomUsageTime = Int.random(in: 5..<30)
                                    
                                    BarMark(
                                       x: .value("Date", date),
                                       y: .value("Time", randomUsageTime)
                                   )
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                        }
                    }
                }
                .padding([.horizontal, .bottom])
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    func setDateString(date: String) -> [String] {
        return date.components(separatedBy: " ")
    }
    
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}


struct LevelCircularProgressBar: View {
    var progress: Double
    var level: Int
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / 100, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text("\(level)")
                .font(.headline)
                .bold()
        }
    }
}

#Preview {
    HomeView(storageManager: StorageManager(), databaseManager: DatabaseManager(), healthManager: HealthManager(), xpManager: XPManager(), pageType: .constant(.home))
}
