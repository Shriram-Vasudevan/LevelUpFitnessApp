//
//  LibraryView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/11/24.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var storageManager: StorageManager
    @ObservedObject var xpManager: XPManager
    
    @State var selectedExercise: ExerciseLibraryExerciseDownloaded?
    
    let bodyAreaKeys = [
            BodyAreas.CodingKeys.back.rawValue,
            BodyAreas.CodingKeys.legs.rawValue,
            BodyAreas.CodingKeys.chest.rawValue,
            BodyAreas.CodingKeys.shoulders.rawValue,
            BodyAreas.CodingKeys.core.rawValue
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
                            ForEach(bodyAreaKeys, id: \.self) { key in
                                VStack (spacing: 0) {
                                    HStack {
                                        Text(key.capitalizingFirstLetter())
                                            .font(.custom("EtruscoNow Medium", size: 25))
                                        
                                        Spacer()
                                        
                                        if let level = userXPData.subLevels.bodyAreas.attribute(for: key)?.level {
                                            Text("Level \(level)")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.horizontal)
                                    
                                    let filteredExercises = storageManager.exercises.filter { $0.bodyArea == key.capitalizingFirstLetter() }
                                        if filteredExercises.isEmpty {
                                            HStack {
                                                Text("No exercises for \(key)")
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                        } else {
                                            ForEach(filteredExercises) { exercise in
                                                ExerciseLibraryExerciseWidget(exerciseLibraryExercise: exercise, userXPData: userXPData)
                                                    .onTapGesture {
                                                        self.selectedExercise = exercise
                                                    }
                                                    .padding(.bottom)
                                            }
                                        }
                                }
                            }
                        }

                    }
                }
            }
            .navigationDestination(item: $selectedExercise) { exercise in
                IndividualExerciseView(exercise: exercise)
            }
        }
    }
}

#Preview {
    LibraryView(storageManager: StorageManager(), xpManager: XPManager())
}
