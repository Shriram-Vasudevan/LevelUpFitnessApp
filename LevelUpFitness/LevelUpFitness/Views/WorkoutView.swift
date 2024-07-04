//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var storageManager: StorageManager
    var programWorkoutManager = ProgramWorkoutManager()
    
    @State var currentExercises: [Exercise] = []
    @State var exerciseDataWidgets: [ExerciseData] = []
    @State var currentExerciseIndex: Int = 0
    
    @State var currentExerciseData: [ExerciseDataWidgetModel] = []
    @State var currentRepIndex: Int = 0
    
    @Environment(\.dismiss) var dismiss
    
    @State var restComplete: (Int) -> Void
    @State var lastRepComplete: (() -> Void)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(.all)
                
                if currentExercises.count > 0 {
                    VStack (spacing: 0) {
                            ZStack {
                                HStack {
                                    Button(action: {
                                        dismiss()
                                        currentExerciseIndex = 0
                                    }, label: {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.white)
                                    })
                                    
                                    Text("Close")
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        Task {
                                            await storageManager.uploadNewProgramStatus(completionHandler: {
                                                dismiss()
                                            })
                                        }
                                    }) {
                                        Text("Save")
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    Spacer()
                                    
                                    Text("Workout")
                                        .bold()
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 10)
                            
                            ScrollView(.vertical) {
                                VStack (spacing: 0) {
                                    Image("GuyAtTheGym")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .cornerRadius(10)
                                        .padding()
                                    
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text(currentExercises[currentExerciseIndex].name)
                                                .font(.headline)
                                                .bold()
                                                .foregroundColor(.black)
                                            
//                                            HStack {
//                                                Image(systemName: "repeat")
//                                                    .foregroundColor(.black)
//                                                
//                                                Text("Reps Per Set: \(currentExercises[currentExerciseIndex].reps)")
//                                                Spacer()
//                                            }
//                                            
//                                            HStack {
//                                                Image(systemName: "timer")
//                                                    .foregroundColor(.black)
//                                                
//                                                Text("Recommended Rest: \(currentExercises[currentExerciseIndex].rest) seconds")
//                                                Spacer()
//                                            }
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                    .padding([.horizontal, .bottom])
                                    
                                    ExerciseDataWidget(exerciseDataWidgetModel: $currentExerciseData[currentRepIndex], index: currentRepIndex, repComplete: $restComplete, lastRepComplete: $lastRepComplete)
                                        .onAppear {
                                            restComplete = { index in
                                                print("s")
                                            }
                                            lastRepComplete = {
                                                moveToNextExercise()
                                            }
                                        }
                                    
                                    Spacer()
                                }
                            }
                            .background(
                                Rectangle()
                                    .fill(.white)
                            )
                            .ignoresSafeArea(.all)
                        }
                }
                else if currentExercises.count - 1 == currentExerciseIndex {
                    // Logic for completing the workout
                }
                else {
                    Text("Hello!")
                }
            }
            .navigationBarBackButtonHidden()
            .onAppear {
                initializeExerciseData()
            }
            .onChange(of: currentExerciseIndex) { oldValue, newValue in
                initializeExerciseData()
            }
        }
    }
    
    func initializeExerciseData() {
        if let todaysProgram = storageManager.program?.program.first(where: { $0.day == programWorkoutManager.getCurrentWeekday() }) {
            self.currentExercises = todaysProgram.exercises
            
            if let (index, _) = todaysProgram.exercises.enumerated().first(where: { $0.element.completed == false }) {
                self.currentExerciseIndex = index
            }
            
            currentExerciseData = []
            for i in 0..<currentExercises[currentExerciseIndex].sets {
                if i == 0 {
                    currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, reps: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, isResting: false, stopRestTimer: false, clear: false, isLast: false))
                } else {
                    currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, reps: 0, time: 0.0, rest: 0.0, isAvailable: false, isStarted: false, isResting: false, stopRestTimer: false, clear: false, isLast: false))
                }
            }
            
            
            print("on appear \(currentExerciseData)")
        } else {
            print("none")
        }
    }
    
    func resetFields() {
        for i in 0..<currentExerciseData.count {
            currentExerciseData[i].clear = true
        }
    }

    func addExerciseData(index: Int) {
        if index + 1 < currentExerciseData.count {
            currentExerciseData[index + 1].isAvailable = true
            
            if index + 1 == currentExerciseData.count - 1 {
                currentExerciseData[index + 1].isLast = true
            }
        }
        else {
            withAnimation {

                currentExercises[currentExerciseIndex].completed = true
                
                if let dayIndex = storageManager.program?.program.firstIndex(where: { $0.day == programWorkoutManager.getCurrentWeekday() }) {
                    storageManager.program?.program[dayIndex].exercises = currentExercises
                    
                    storageManager.program?.program[dayIndex].exercises[currentExerciseIndex].data = getAllExerciseDatas()

                }
                
                resetFields()
            }
        }
    }
    
    func getAllExerciseDatas() -> [ExerciseData] {
        let exerciseDataArray = currentExerciseData.map { ExerciseData(from: $0) }
        return exerciseDataArray
    }

    func moveToNextRep() {
        currentRepIndex += 1
    }
    
    func moveToNextExercise() {
        if currentExerciseIndex < currentExercises.count - 1 {
            print("upping index")
            currentExerciseIndex += 1
        }
    }
}


#Preview {
    WorkoutView(storageManager: StorageManager(), restComplete: {_ in }, lastRepComplete: {})
}

