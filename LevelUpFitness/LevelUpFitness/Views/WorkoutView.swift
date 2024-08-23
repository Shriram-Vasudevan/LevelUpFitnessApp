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
    
    @State private var setCompleted: () -> Void = {}
    @State private var lastSetCompleted: () -> Void = {}
    
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
                    WorkoutContent(workoutManager: workoutManager, programManager: programManager, xpManager: xpManager, dismiss: dismiss, setCompleted: $setCompleted, lastSetCompleted: $lastSetCompleted)
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                workoutManager.initializeExerciseData() 
                setupCallbacks()
            }
        }
    }
    
    private func setupCallbacks() {
        setCompleted = {
            print("Moving to next set")
            workoutManager.moveToNextSet()
        }
        
        lastSetCompleted =  {
            print("Moving to next exercise")
            workoutManager.moveToNextExercise()
        }
    }
}

struct WorkoutContent: View {
    @ObservedObject var workoutManager: WorkoutManager
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var xpManager: XPManager
    
    var dismiss: DismissAction
    @Binding var setCompleted: () -> Void
    @Binding var lastSetCompleted: () -> Void
    
    var body: some View {
        VStack (spacing: 0) {
            WorkoutHeader(dismiss: dismiss)
            
            ExerciseDataSetWidget(
                model: $workoutManager.currentExerciseData.sets[workoutManager.currentSetIndex],
                isLastSet: workoutManager.onLastSet,
                setIndex: workoutManager.currentSetIndex,
                setCompleted: $setCompleted,
                lastSetCompleted: $lastSetCompleted,
                exerciseName: workoutManager.currentExercises[workoutManager.currentExerciseIndex].name, exerciseReps: workoutManager.currentExercises[workoutManager.currentExerciseIndex].reps, numberOfSets: workoutManager.currentExerciseData.sets.count, exitWorkout: {
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
            )
            .id("\(workoutManager.currentExerciseIndex)-\(workoutManager.currentSetIndex)")
            .onChange(of: workoutManager.programCompletedForDay, { oldValue, newValue in
                if newValue {
                    dismiss()
                    
                    GlobalCoverManager.shared.showProgramDayCompletion()
                }
            })
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(.white)
            )
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    func getCurrentWeekday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: date)
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

