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
                HStack {
                    Text("LevelUp Fitness")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                    
                    Spacer()
                    
                    Image(systemName: "gearshape")
                        .foregroundColor(.black)
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.horizontal)
                
                ScrollView(.vertical) {
                    VStack (spacing: 0) {
                        HStack {
                            Text("Today's Video")
                                .font(.custom("EtruscoNowCondensed Bold", size: 30))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 0) {
                            if let url = storageManager.dailyVideo {
                                VideoPlayer(player: avPlayer)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: .infinity, height: 200)
                                    .onAppear {
                                        avPlayer = AVPlayer(url: url)
                                    }
                                    .cornerRadius(10)

                            } else {
                                Rectangle()
                                    .fill(.white)
                                    .frame(width: .infinity, height: 200)
                                    .overlay (
                                        Image("GuyAtTheGym")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .padding(.horizontal)
                                            .clipped()
                                    )
                                    .cornerRadius(10)
                            }
                            
//                            HStack {
//                               VStack {
//                                   HStack {
//                                       Text("Leg Exercises")
//                                           .font(.custom("Sailec Bold", size: 23))
//                                           .foregroundColor(.black)
//                                           .textCase(.uppercase)
//                                       
//                                       Spacer()
//                                       
//                                   }
//                                   
//                                   HStack {
//                                       Text("Exercises to Strengthen your Legs")
//                                           .font(.custom("Sailec Medium", size: 15))
//                                           .foregroundColor(.gray)
//                                       
//                                       Spacer()
//                                   }
//                               }
//                               
//                               Spacer()
//                               
//                               VStack {
//                                   Text("25")
//                                       .font(.custom("Sailec Bold", size: 20))
//                                   
//                                   Text("MAY")
//                                       .font(.custom("Sailec Bold", size: 20))
//                               }
//                           }
//                           .padding()
//                           .background(
//                               Rectangle()
//                                   .fill(Color(red: 250/255.0, green: 245/255.0, blue: 245/255.0))
//                           )
                        }
                        .padding(.horizontal)
                        .cornerRadius(15)
                        
                        HStack {
                            Text("Your Stats")
                                .font(.custom("EtruscoNowCondensed Bold", size: 30))
                            
                            Spacer()
                        }
                        .padding([.horizontal, .bottom])
                        
            
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
                        
                        VStack {
                            HStack {
                                ZStack {
                                    Text("56")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                        .bold()
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                    .shadow(radius: 5)
                            )
                            .padding(.bottom, 5)
                            
                            Text("Percentage of your Program Completed this Week")
                                .font(.footnote)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.white)
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
        }
        .onAppear {
            Task {
                if storageManager.dailyVideo == nil {
                    await storageManager.downloadDailyVideo()
                }
                
                if databaseManager.workouts.count <= 0 {
                    await databaseManager.getWorkouts()
                }
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
