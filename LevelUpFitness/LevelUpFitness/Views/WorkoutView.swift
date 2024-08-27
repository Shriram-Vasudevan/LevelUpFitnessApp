//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI

struct WorkoutView: View {
    @StateObject private var workoutManager: WorkoutManager
    @ObservedObject private var programManager: ProgramManager
    @ObservedObject private var xpManager: XPManager
    
    @Environment(\.dismiss) var dismiss
    
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
                    WorkoutContent(workoutManager: workoutManager, programManager: programManager, xpManager: xpManager, dismiss: dismiss)
                }
            }
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
    
    var dismiss: DismissAction
    
    var body: some View {
        VStack (spacing: 0) {
            WorkoutHeader(dismiss: dismiss)
            
            HStack {
                VStack (alignment: .center, spacing: 0) {
                    HStack {
                        Text(workoutManager.currentExercises[workoutManager.currentExerciseIndex].name)
                            .font(.custom("EtruscoNowCondensed Bold", size: 50))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, -7)
                            .padding(.top, -10)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Reps per Set: \(workoutManager.currentExercises[workoutManager.currentExerciseIndex].reps)")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.bottom)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
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
                .edgesIgnoringSafeArea(.bottom)
        })
        .onChange(of: workoutManager.programCompletedForDay, { oldValue, newValue in
            if newValue {
                dismiss()
                
                GlobalCoverManager.shared.showProgramDayCompletion()
            }
        })
        .id(workoutManager.currentExerciseIndex)
    }
    
    func getCurrentWeekday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: date)
    }
    
    func exitWorkout() {
        Task {
            if let todaysProgram = programManager.program?.program.first(where: { $0.day == getCurrentWeekday() }) {
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


struct WorkoutHeader: View {
    @State var timeText: String = "00:00"
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    var dismiss: DismissAction

    var body: some View {
        ZStack {
            HStack {
                Text("Workout Time")
                    .font(.custom("EtruscoNowCondensed Bold", size: 35))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(timeText)
                    .font(.custom("Sailec Bold", size: 30))
                    .foregroundColor(.white)
                    .padding(.top, 5)
            }
            .padding(.horizontal)
       }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func startTimer() {
            elapsedTime = 0.0
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                elapsedTime += 0.1
                let minutes = Int(elapsedTime) / 60
                let seconds = Int(elapsedTime) % 60
                timeText = String(format: "%02d:%02d", minutes, seconds)
            })
        }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


#Preview {
    WorkoutView(programManager: ProgramManager(), xpManager: XPManager())
}

