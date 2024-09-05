//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI
import AVKit

struct WorkoutView: View {
    @StateObject private var workoutManager: WorkoutManager
    @ObservedObject private var programManager: ProgramManager
    @ObservedObject private var xpManager: XPManager
    
    @Environment(\.dismiss) var dismiss
    
    @State var navigateToExerciseVideoView: Bool = false
    
    init(programManager: ProgramManager, xpManager: XPManager) {
        _workoutManager = StateObject(wrappedValue: WorkoutManager(programManager: programManager, xpManager: xpManager))
        self.programManager = programManager
        self.xpManager = xpManager
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 248/255.0, green: 4/255.0, blue: 76/255.0)
                    .edgesIgnoringSafeArea(.all)
                
                if !workoutManager.hasExercisesForToday() {
                    Text("No exercises for today")
                        .foregroundColor(.white)
                } else if workoutManager.isWorkoutComplete() {
                    Text("Workout completed!")
                        .foregroundColor(.white)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                dismiss()
                            }
                        }
                } else {
                    WorkoutContent(workoutManager: workoutManager, programManager: programManager, xpManager: xpManager, navigateToExerciseVideoView: $navigateToExerciseVideoView, dismiss: dismiss)
                }
            }
            .navigationDestination(isPresented: $navigateToExerciseVideoView, destination: {
                if workoutManager.currentExerciseIndex < workoutManager.currentExercises.count {
                    FullPageVideoView(cdnURL: workoutManager.currentExercises[workoutManager.currentExerciseIndex].cdnURL)
                } else {
                    Text("No video available").foregroundColor(.white)
                }
            })
            .navigationBarBackButtonHidden()
            .onAppear {
                workoutManager.initializeExerciseData()
            }
        }
    }
}

struct WorkoutContent: View {
    @ObservedObject var workoutManager: WorkoutManager
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var xpManager: XPManager
    
    @Binding var navigateToExerciseVideoView: Bool
    
    var dismiss: DismissAction
    
    @State private var avPlayer = AVPlayer()
    
    var body: some View {
        VStack (spacing: 0) {
            VStack (spacing: 0) {
                ZStack
                {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                        
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Text("Exercise")
                        .font(.custom("Sailec Bold", size: 20))
                        .foregroundColor(.black)
                }
                .padding(.bottom)
                
                if let videoURL = URL(string: workoutManager.currentExercises[workoutManager.currentExerciseIndex].cdnURL) {
                    VideoPlayer(player: avPlayer)
                        .aspectRatio(16/9, contentMode: .fit)
                        .onAppear {
                            avPlayer = AVPlayer(url: videoURL)
                            avPlayer.play()
                        }
                        .padding(.horizontal)
                } else {
                    Text("Retrieving Video")
                }
                
                HStack {
                    Text(workoutManager.currentExercises[workoutManager.currentExerciseIndex].name)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Reps per Set: \(workoutManager.currentExercises[workoutManager.currentExerciseIndex].reps)")
                        .font(.system(size: 20, weight: .light, design: .rounded))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
        
            ScrollView(.vertical) {
                
                ForEach(Array(workoutManager.currentExerciseData.sets.enumerated()), id: \.offset) { index, set in
                    let isCurrentSet = index == workoutManager.currentSetIndex
                    let isWeightExercise = workoutManager.currentExercises[workoutManager.currentExerciseIndex].isWeight
                    
                    ProramExerciseDataSetWidget(
                        model: $workoutManager.currentExerciseData.sets[index],
                        setIndex: index,
                        setCompleted: {
                            workoutManager.moveToNextSet()
                        },
                        isWeight: isWeightExercise
                    )
                    .disabled(!isCurrentSet)
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isCurrentSet ? Color.black : Color.white, lineWidth: 2)
                    )
                    .padding()
                }
                
                
                Button(action: {
                    exitWorkout()
                }, label: {
                    Image(systemName: "flag.checkered.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 5)
                })
            }
        }
        .background(content: {
            Rectangle()
                .fill(.white)
                .edgesIgnoringSafeArea(.all)
        })
        .onChange(of: workoutManager.programCompletedForDay, { oldValue, newValue in
            if newValue {
                dismiss()
                
                GlobalCoverManager.shared.showProgramDayCompletion()
            }
        })
        .id(workoutManager.currentExerciseIndex)
    }
    
    func exitWorkout() {
        Task {
            if let todaysProgram = programManager.program?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() }) {
                print("uploading new status")
                await programManager.uploadNewProgramStatus(completion: { success in
                        if success {
                            dismiss()
                        } else {
                            
                        }
                    })
            }
        }
    }
}



#Preview {
    WorkoutView(programManager: ProgramManager(), xpManager: XPManager())
}

