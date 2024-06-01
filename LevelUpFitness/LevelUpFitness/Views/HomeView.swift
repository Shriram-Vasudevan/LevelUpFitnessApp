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
    
    @State var avPlayer = AVPlayer()
    
//    @State var date: [String] = ["", ""]
    
    @State var days: [String: String] = ["5/20" : "Happy", "5/21" : "Happy", "5/22" : "Happy", "5/23" : "Happy", "5/24" : "Happy", "5/25" : "Happy", "5/26" : "Happy"]
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                VStack {
                    HStack {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(.white)
                            .hidden()
                        
                        Spacer()
                        
                        Text("LevelUp Fitness")
                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .foregroundColor(.white)
                           // .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 15)
                           
                    }
                    .padding(.top, 50)
                    .padding(.horizontal)
                }
                .background(
                    Rectangle()
                        .fill(.blue)
                )
                .edgesIgnoringSafeArea(.top)

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
                        .padding(.horizontal)
                        .cornerRadius(15)
                        .padding(.bottom, 5)
                        HStack {
                            VStack (alignment: .leading) {
                                Text("Leg Raises")
                                    .font(.headline)
                                    .bold()
                                
                                Text("Daily Exercises")
                            }

                            Spacer()
                            
                            VStack {
                                Text("31")
                                    .font(.custom("Sailec Bold", size: 20))
                                
                                Text("MAY")
                                    .font(.custom("Sailec Bold", size: 20))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.white)
                                .shadow(radius: 5)
                            
                        )
                        .padding([.horizontal, .bottom])
                        
                        VStack {
                            HStack {
                                ZStack {
                                    Text("56")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                        .shadow(radius: 5)
                                )
                                .padding(.bottom, 5)
                                
                                Spacer()
                                
                                Text("Percentage of your Program Completed this Week")
                                    .bold()
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                
                                Spacer()
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
                            .padding()
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                        
                        if databaseManager.workouts.count > 0 {
                            HStack {
                                Text("Workouts")
                                    .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                
                                Spacer()
                                
                                Text("Show All")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            
                            
                            VStack (spacing: 10) {
                                ForEach(databaseManager.workouts.prefix(2), id: \.id) { workout in
                                    WorkoutCard(workout: workout)
                                }
                            }
                            .padding(.top, 1)
                            .padding(.bottom)
                        }
                        
                        Spacer()
                    }
                }
                .padding(.top, -40)
            }
            
        }
    }
    
    func setDateString(date: String) -> [String] {
        return date.components(separatedBy: " ")
    }
}

#Preview {
    HomeView(storageManager: StorageManager(), databaseManager: DatabaseManager())
}
