//
//  TrainView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct TrainView: View {
    @ObservedObject var databaseManager: DatabaseManager
    @ObservedObject var storageManager: StorageManager
    
    @State var navigateToProgramView: Bool = false
    
    var body: some View {
        NavigationStack {
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
                        
                        if storageManager.retrievingProgram {
                            VStack {
                                ZStack {
                                    Image("ManExercising - PushUp")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                
                                Text("We're Getting your Program!}")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                Rectangle()
                                    .fill(.white)
                                    .shadow(radius: 5)
                            )
                            .padding(.horizontal)
                            .padding(.bottom)
                        } else if storageManager.program != nil {
                            VStack {
                                ZStack {
                                    Image("ManExercising - PushUp")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                
                                Text("Begin Workout")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                Rectangle()
                                    .fill(.white)
                                    .shadow(radius: 5)
                            )
                            .padding(.horizontal)
                            .padding(.bottom)
                            .onTapGesture {
                                navigateToProgramView = true
                            }
                        } else {
                            VStack {
                                ZStack {
                                    Image("ManExercising - PushUp")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                                
                                Text("You Have no Program!")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                Rectangle()
                                    .fill(.white)
                                    .shadow(radius: 5)
                            )
                            .padding(.horizontal)
                            .padding(.bottom)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToProgramView) {
                if let program = storageManager.program {
                    WorkoutView(storageManager: storageManager)
                }
            }
        }
    }
}

#Preview {
    TrainView(databaseManager: DatabaseManager(), storageManager: StorageManager())
}
