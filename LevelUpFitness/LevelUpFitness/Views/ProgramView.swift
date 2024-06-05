//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import SwiftUI

struct ProgramView: View {
    @ObservedObject var storageManager: StorageManager
    
    @State var navigateToWorkoutView: Bool = false
    
    @State var buttonHeight: CGFloat = 200
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
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
                        
                        Text("Your Program")
                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(systemName: "line.3.horizontal")
                            .resizable()
                            .foregroundColor(.white)
                           // .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 15)
                    }
                    .padding(.horizontal)
                    
                    VStack {
                        ScrollView(.vertical) {
                            VStack (spacing: 0) {
                                ProgramListWidget(storageManager: storageManager, navigateToWorkoutView: $navigateToWorkoutView)
                                    .padding(.top)
                                   
                                GeometryReader { geometry in
                                    let totalWidth = geometry.size.width
                                    let padding: CGFloat = 10
                                    let squareWidth = (totalWidth - padding) / 2
                                    
                                    HStack(spacing: padding) {
                                        Button(action: {
                                            
                                        }, label: {
                                            Rectangle()
                                                .fill(.white)
                                                .frame(width: squareWidth, height: squareWidth)
                                                .shadow(radius: 5)
                                                .overlay (
                                                    Text("Message \nLuke")
                                                        .font(.custom("Sailec Bold", size: 25))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black)
                                                        .padding(),
                                                    alignment: .topLeading
                                                )
                                                .overlay (
                                                    Image("Chat")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 40, height: 40)
                                                        .padding(),
                                                    alignment: .bottomTrailing
                                                )
                                        })
                                        
                                        Button(action: {
                                            
                                        }, label: {
                                            Rectangle()
                                                .fill(.white)
                                                .frame(width: squareWidth, height: squareWidth)
                                                .shadow(radius: 5)
                                                .overlay (
                                                    Text("Your \nMetrics")
                                                        .font(.custom("Sailec Bold", size: 25))
                                                        .multilineTextAlignment(.leading)
                                                        .foregroundColor(.black)
                                                        .padding(),
                                                    alignment: .topLeading
                                                )
                                                .overlay (
                                                    Image("PieChart")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 60, height: 60)
                                                        .padding(),
                                                    alignment: .bottomTrailing
                                                )
                                        })
                                    }
                                }
                                .frame(height: (UIScreen.main.bounds.width - 10) / 2)
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Achievements")
                                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                VStack (spacing: 15) {
                                    AchievementWidget()
                                    AchievementWidget()
                                    AchievementWidget()
                                    AchievementWidget()
                                }
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
                .onTapGesture {
                    navigateToWorkoutView = true
                }
            }
            .fullScreenCover(isPresented:  $navigateToWorkoutView, content: {
                WorkoutView(storageManager: storageManager)
            })
//            .navigationDestination(isPresented: $navigateToWorkoutView, destination: {
//                WorkoutView(storageManager: storageManager)
//            })
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    ProgramView(storageManager: StorageManager())
}

