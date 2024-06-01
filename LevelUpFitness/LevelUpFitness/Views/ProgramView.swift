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
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack (spacing: 0) {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Text("Your Program")
                                .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.top, 50)
                        .padding(.horizontal)
                    }
                    .background(
                        Rectangle()
                            .fill(.blue)
                    )
                    .edgesIgnoringSafeArea(.top)
                    
                    HStack {
                        Text("Today's Program")
                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                        
                        Spacer()
                    }
                    .padding([.horizontal, .bottom])
                    .padding(.top, -40)
                    
                    ProgramListWidget(storageManager: storageManager, navigateToWorkoutView: $navigateToWorkoutView)
                    
                    HStack {
                        Text("Bonus Exercises")
                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                        
                        Spacer()
                    }
                    .padding([.horizontal, .bottom])
                    
                    Spacer()
                }
                .onTapGesture {
                    navigateToWorkoutView = true
                }
            }
            .navigationDestination(isPresented: $navigateToWorkoutView, destination: {
                WorkoutView(storageManager: storageManager)
            })
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    ProgramView(storageManager: StorageManager())
}

