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
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        })
                        
                        Text("Exit")
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Today's Program")
                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                        
                        Spacer()
                    }
                    .padding([.horizontal, .bottom])
                    
                    ProgramListWidget(storageManager: StorageManager(), navigateToWorkoutView: $navigateToWorkoutView)
                    
                    
                    HStack {
                        Text("Bonus Exercises")
                            .font(.custom("EtruscoNowCondensed Bold", size: 35))
                        
                        Spacer()
                    }
                    .padding([.horizontal, .bottom])
                    
                    Spacer()
                    
                }
            }
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $navigateToWorkoutView) {
                WorkoutView(storageManager: storageManager)
            }
        }
    }
}

#Preview {
    ProgramView(storageManager: StorageManager())
}
