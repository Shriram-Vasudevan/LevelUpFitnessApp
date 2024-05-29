//
//  TrainView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct TrainView: View {
    @State var databaseManager: DatabaseManager
    @State var storageManager: StorageManager
    
    @State var navigateToProgramView: Bool = false
    
    var body: some View {
        NavigationStack {
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
                        }
                        
                        
                    }
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $navigateToProgramView) {
                if let program = storageManager.program {
                    ProgramView(program: program)
                }
            }
        }
    }
}

#Preview {
    TrainView(databaseManager: DatabaseManager(), storageManager: StorageManager())
}
