//
//  TrainView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct TrainView: View {
    @State var databaseManager: DatabaseManager
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                HStack {
                    Text("Workouts")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                    
                    Spacer()
                    
                    Text("Show All")
                        .foregroundColor(.blue)
                }
                .padding([.horizontal, .bottom])
                
                ScrollView(.vertical) {
                    VStack (spacing: 0) {
                        VStack (spacing: 10) {
                            ForEach(databaseManager.workouts.prefix(2), id: \.id) { workout in
                                WorkoutCard(workout: workout)
                            }
                        }
                        .padding(.top, 1)
                        .padding(.bottom)
                        
                        HStack {
                            Text("Your Program")
                                .font(.custom("EtruscoNowCondensed Bold", size: 35))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Maximized Muscle Manipulation Program: Aesthetic")
                            
                            Spacer()
                        }
                        .padding([.horizontal, .bottom])
                        
                        VStack {
                            HStack {
                                Text("Monday")
                                    .font(.title)
                                    .bold()
                                
                                Spacer()
                                
                                Image(systemName: "chevron.left")
                                Image(systemName: "chevron.right")
                            }
                            
                            Divider()
                                .padding(.bottom, 5)
                            
                            VStack (spacing: 5) {
                                HStack {
                                    Text("1: Barbell Back Squat")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Text("2: Bulgarian split squat")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Text("2a: RDL")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Text("3: Cannon Ball Squat")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                                
                                HStack {
                                    Text("3a: Step up")
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("3b: Adductor Machine")
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("4: Side squat")
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Text("4a: Leg Extenstions")
                                    
                                    Spacer()
                                }
                                
                            }
                            
                            Button(action: {
                                
                            }) {
                                Text("Resume")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding(20)
                                    .background(.blue)
                                    .cornerRadius(15)
                            }
                            .padding(.top, 15)
                            
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
//                                .fill(LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .fill(.white)
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                    }
                    
                    
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    TrainView(databaseManager: DatabaseManager())
}
