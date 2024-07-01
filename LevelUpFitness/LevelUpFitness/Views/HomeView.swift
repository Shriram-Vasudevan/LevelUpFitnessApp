import SwiftUI
import Charts
import AVKit


struct HomeView: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var databaseManager: DatabaseManager
    @ObservedObject var healthManager: HealthManager
    
    @State var avPlayer = AVPlayer()
    
    @State var days: [String: String] = ["5/20" : "Happy", "5/21" : "Happy", "5/22" : "Happy", "5/23" : "Happy", "5/24" : "Happy", "5/25" : "Happy", "5/26" : "Happy"]
    
    @Binding var pageType: PageType
    
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack (spacing: 0) {
                HStack {
                    Circle()
                        .fill(.yellow)
                        .frame(width: 25, height: 25)
                        .overlay (
                            Text("2")
                        )
                    
                    Spacer()
                    
                    Text("LevelUp Fitness")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 15)
                }
                .padding(.horizontal)
                
                VStack (spacing: 0) {
                    ScrollView(.vertical) {
                        VStack (spacing: 10) {
                            HStack {
                                LevelCircularProgressBar(progress: 35, level: 2)
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
                            
                            Divider()
                            
                            TabView () {
                                VStack {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Complete some Exercises")
                                                .font(.headline)
                                            Text("More coming soon!")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    Button(action: {
                                        self.pageType = .library
                                    }, label: {
                                        Text("Go to Library")
                                    })
                                }
                                .getSizeOfView { contentSize = $0 }
                                
                                VStack {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Today's Program")
                                                .font(.headline)
                                            Text("Complete the program to level up!")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    
                                    if let todaysProgram = storageManager.program?.program.first(where: { $0.day == getCurrentWeekday() }) {
                                        
                                        if !todaysProgram.completed {
                                            HStack {
                                                Text("Complete the program to level up!")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        } else {
                                            HStack {
                                                Text("You have completed today's program!")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                    }
                                }
                                .getSizeOfView { contentSize = $0 }
                            }
                            .frame(minHeight: 80, idealHeight: contentSize.height)
                            .tabViewStyle(.page(indexDisplayMode: .never))
                            
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.white)
                                .shadow(radius: 2)
                        )
                        .padding()
                        
                        VStack(spacing: 0) {
                            if let url = storageManager.dailyVideo {
                                VideoPlayer(player: avPlayer)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .onAppear {
                                        avPlayer = AVPlayer(url: url)
                                    }
                                    .cornerRadius(10)
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.black, lineWidth: 2)
                                    )

                            } else {
                                Rectangle()
                                    .fill(.white)
                                    .stroke(.black, lineWidth: 2)
                                    .frame(height: 200)
                                    .overlay (
                                        Image("GuyAtTheGym")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .padding(.horizontal)
                                            .clipped()
                                    )
                                    .cornerRadius(10)
                            }
                        }
                        .padding()
                        .padding(.bottom, 5)
                        .cornerRadius(15)
                        
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
                .background(
                    Rectangle()
                        .fill(.white)
                )
                .ignoresSafeArea(.all)
            }
        }
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
                .foregroundColor(Color.yellow)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / 100, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.yellow)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text("\(level)")
                .font(.headline)
                .bold()
        }
    }
}

#Preview {
    HomeView(storageManager: StorageManager(), databaseManager: DatabaseManager(), healthManager: HealthManager(), pageType: .constant(.home))
}
