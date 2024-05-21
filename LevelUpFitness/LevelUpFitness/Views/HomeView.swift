//
//  HomeView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/14/24.
//

import SwiftUI
import AVKit

struct HomeView: View {
    @ObservableObject var storageManager = StorageManager()
    
    @State var avPlayer = AVPlayer()
    
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
                
                HStack {
                    Text("Today's Video")
                        .font(.custom("EtruscoNowCondensed Bold", size: 30))
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                VStack(spacing: 0) {
                    if let url = storageManager.dailyVideo {
                        VideoPlayer(player: avPlayer)
                            .frame(width: .infinity, height: 200)
                            .onAppear {
                                avPlayer = AVPlayer(url: url)
                            }
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
                    }
                    
                    HStack {
                       VStack {
                           HStack {
                               Text("Leg Exercises")
                                   .font(.custom("Sailec Bold", size: 23))
                                   .foregroundColor(.black)
                                   .textCase(.uppercase)
                               
                               Spacer()
                               
                           }
                           
                           HStack {
                               Text("Exercises to Strengthen your Legs")
                                   .font(.custom("Sailec Medium", size: 15))
                                   .foregroundColor(.gray)
                               
                               Spacer()
                           }
                       }
                       
                       Spacer()
                       
                       VStack {
                           Text("14")
                               .font(.custom("Sailec Bold", size: 20))
                           
                           Text("MAY")
                               .font(.custom("Sailec Bold", size: 20))
                       }
                   }
                   .padding()
                   .background(
                       Rectangle()
                           .fill(Color(red: 250/255.0, green: 245/255.0, blue: 245/255.0))
                   )
                }
                .padding(.horizontal)
                .cornerRadius(3)
                
                HStack {
                    Text("Your Stats")
                        .font(.custom("EtruscoNowCondensed Bold", size: 30))
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
}
