//
//  LibraryView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var xpManager: XPManager
    @ObservedObject var exerciseManager: ExerciseManager
    
    @State var selectedExercise: Progression?
    
    let exerciseTypeKeys = [
        Sublevels.CodingKeys.lowerBodyCompound.rawValue,
        Sublevels.CodingKeys.lowerBodyIsolation.rawValue,
        Sublevels.CodingKeys.upperBodyCompound.rawValue,
        Sublevels.CodingKeys.upperBodyIsolation.rawValue
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 240 / 255.0, green: 244 / 255.0, blue: 252 / 255.0)
                    .ignoresSafeArea(.all)
                
                ScrollView(.vertical) {
                    VStack (spacing: 0) {
                        HStack {
                            Text("LevelUp Library")
                                .font(.custom("EtruscoNow Medium", size: 30))
                            
                            
                            Spacer()
                            
                            Image(systemName: "bell")
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(height: UIScreen.main.bounds.height / 4)
                            .shadow(radius: 7)
                            .overlay(
                                Image("PersonRunningForward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(.vertical)
                                    .padding(.leading),
                                alignment: .trailing
                            )
                            .overlay(
                                Text("Check out Our New Additions!")
                                    .bold()
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))
                                    .padding(),
                                alignment: .bottomLeading
                            )
                            .padding(.horizontal)
                            .padding(.bottom)
                        
                        
                        if let userXPData = xpManager.userXPData {
                            ForEach(exerciseTypeKeys, id: \.self) { key in
                                VStack (spacing: 0) {
                                    HStack {
                                        Text(key.capitalizingFirstLetter())
                                            .font(.custom("EtruscoNow Medium", size: 25))
                                        
                                        Spacer()
                                        
                                        if let level = userXPData.subLevels.attribute(for: key)?.level {
                                            Text("Level \(level)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal)
//                                    
//                                    let filteredExercises = exerciseManager.exercises.filter { $0.exerciseType == key.capitalizingFirstLetter() }
//                                        if filteredExercises.isEmpty {
//                                            HStack {
//                                                Text("No exercises for \(key)")
//                                                
//                                                Spacer()
//                                            }
//                                            .padding(.horizontal)
//                                        } else {
//                                            ForEach(filteredExercises, id: \.id) { exercise in
//                                                ExerciseLibraryExerciseWidget(exerciseLibraryExercise: exercise, userXPData: userXPData, exerciseSelected: {
//                                                    self.selectedExercise = exercise
//                                                })
//                                                    
//                                                    .padding(.bottom)
//                                            }
//                                        }
                                }
                            }
                        }

                    }
                }
            }
            .navigationDestination(item: $selectedExercise) { exercise in
                IndividualExerciseView(progression: exercise)
            }
        }
    }
}

#Preview {
    LibraryView(programManager: ProgramManager(), xpManager: XPManager(), exerciseManager: ExerciseManager())
}
