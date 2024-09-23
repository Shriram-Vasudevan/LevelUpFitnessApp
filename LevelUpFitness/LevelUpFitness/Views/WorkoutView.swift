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
    @State private var showDescriptionPopup: Bool = false
    
    init(programManager: ProgramManager, xpManager: XPManager) {
        _workoutManager = StateObject(wrappedValue: WorkoutManager(programManager: programManager, xpManager: xpManager))
        self.programManager = programManager
        self.xpManager = xpManager
    }
    
    var body: some View {
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
                WorkoutContent(workoutManager: workoutManager, programManager: programManager, xpManager: xpManager, navigateToExerciseVideoView: $navigateToExerciseVideoView, showDescriptionPopup: $showDescriptionPopup, dismiss: dismiss)
            }
            
            if showDescriptionPopup {
                ExerciseDescriptionView(description: workoutManager.currentExercises[workoutManager.currentExerciseIndex].description, isOpen: $showDescriptionPopup)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showDescriptionPopup)
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

struct WorkoutContent: View {
    @ObservedObject var workoutManager: WorkoutManager
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var xpManager: XPManager
    
    @Binding var navigateToExerciseVideoView: Bool
    @Binding var showDescriptionPopup: Bool
    
    var dismiss: DismissAction
    
    @State private var avPlayer = AVPlayer()
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ZStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                exitWorkout()
                            }, label: {
                                Text("Finish")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(7)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "0077FF")]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            })
                        }
                        .padding(.horizontal)

                        Text("Exercise")
                            .font(.custom("Sailec Bold", size: 20))
                            .foregroundColor(.black)
                    }
                    .padding(.bottom)

                    if let videoURL = URL(string: workoutManager.currentExercises[workoutManager.currentExerciseIndex].cdnURL), !workoutManager.currentExercises[workoutManager.currentExerciseIndex].cdnURL.isEmpty, workoutManager.currentExercises[workoutManager.currentExerciseIndex].cdnURL != "nil" {
                        VideoPlayer(player: avPlayer)
                            .aspectRatio(16/9, contentMode: .fit)
                            .onAppear {
                                avPlayer = AVPlayer(url: videoURL)
                                avPlayer.play()
                            }
                            .padding(.horizontal)
                    } else {
                        VStack {
                            Text("No video available")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            Button(action: {
                                showDescriptionPopup = true
                            }) {
                                Text("See Description")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(
                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color(hex: "40C4FC"), Color(hex: "0077FF")]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                    )
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal)
                    }

                    HStack {
                        Text(workoutManager.currentExercises[workoutManager.currentExerciseIndex].name)
                            .font(.system(size: 20, weight: .medium, design: .default))

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 7)
                }

                if workoutManager.currentSetIndex < workoutManager.currentExerciseData.sets.count {
                    ProgramExerciseDataSetWidget(
                        model: $workoutManager.currentExerciseData.sets[workoutManager.currentSetIndex], exercise: workoutManager.currentExercises[workoutManager.currentExerciseIndex],
                        setIndex: workoutManager.currentSetIndex, totalSets: workoutManager.currentExerciseData.sets.count,
                        setCompleted: {
                            completeCurrentSet()
                        }
                    )
                    .id(UUID().uuidString)
                }
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

    func completeCurrentSet() {
        workoutManager.moveToNextSet()
    }

    func exitWorkout() {
        Task {
            if (ProgramManager.shared.selectedProgram?.program.first(where: { $0.day == DateUtility.getCurrentWeekday() })) != nil {
                print("uploading new status")
                await programManager.uploadNewProgramStatus(programName: ProgramManager.shared.selectedProgram?.programName ?? "" , completion: { success in
                    if success {
                        dismiss()
                    }
                })
            }
        }
    }
}

struct ExerciseDescriptionView: View {
    var description: String
    
    @Binding var isOpen: Bool

    @State private var offsetValue: CGFloat = UIScreen.main.bounds.height
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            if isOpen {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isOpen = false
                        }
                    }
            }
            
            VStack {
                Text("Exercise Description")
                    .font(.title2)
                    .padding()
                
                Text(description)
                    .font(.body)
                    .padding()
                
                Button("Close") {
                    isOpen = false
                }
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "40C4FC"))
            }
            .padding()
            .background(Color.white)
            .padding()
            .offset(y: offsetValue)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3)) {
                    offsetValue = 0
                }
            }
            .onDisappear {
                withAnimation {
                    offsetValue = UIScreen.main.bounds.height
                }
            }
        }
    }
}

#Preview {
    WorkoutView(programManager: ProgramManager(), xpManager: XPManager())
}

