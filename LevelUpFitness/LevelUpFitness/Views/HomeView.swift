//
//  HomeView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI
import Charts
import AVKit

struct HomeView: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var databaseManager: DatabaseManager
    @ObservedObject var healthManager: HealthManager
    
    @State var avPlayer = AVPlayer()
    
//    @State var date: [String] = ["", ""]
    
    @State var days: [String: String] = ["5/20" : "Happy", "5/21" : "Happy", "5/22" : "Happy", "5/23" : "Happy", "5/24" : "Happy", "5/25" : "Happy", "5/26" : "Happy"]
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            
            VStack (spacing: 0) {
                HStack {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 20, height: 15)
                        .hidden()
                    
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
                
                VStack {
                    ScrollView(.vertical) {
                        VStack (spacing: 0) {
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
                            
                            if databaseManager.workouts.count > 0 {
                                HStack {
                                    Text("Workouts")
                                        .font(.custom("Sailec Bold", size: 20))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 7)
                                
                                
                                VStack (spacing: 10) {
                                    ForEach(databaseManager.workouts.prefix(2), id: \.id) { workout in
                                        WorkoutCard(workout: workout)
                                    }
                                }
                                .padding(.top, 1)
                                .padding(.bottom)
                            }
                            
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
}

#Preview {
    HomeView(storageManager: StorageManager(), databaseManager: DatabaseManager(), healthManager: HealthManager())
}
