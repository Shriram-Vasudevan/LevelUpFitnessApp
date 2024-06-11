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
    
    @Environment(\.dismiss) var dismiss
    
    @State var onStartSet: (Int) -> Void
    @State var onDataEntryCompleteHandler: (Int) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(.all)
                
                if currentExercises.count > 0 {
                        VStack {
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
                            
                            ScrollView(.vertical) {
                                VStack (spacing: 0) {
                                    Image("GuyAtTheGym")
                                        .resizable()
                                        .frame(height:  200)
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    
                                    
                                    HStack {
                                        VStack (alignment: .leading, spacing: 0) {
                                            Text(currentExercises[currentExerciseIndex].name)
                                                .font(.custom("EtruscoNowCondensed Bold", size: 35))
                                                .padding(.bottom, -7)
                                            
                                            HStack {
                                                Image(systemName: "repeat")
                                                    .foregroundColor(.black)
                                                
                                                Text("Reps Per Set: \(currentExercises[currentExerciseIndex].reps)")
                                                Spacer()
                                            }
                                            
                                            HStack {
                                                Image(systemName: "timer")
                                                    .foregroundColor(.black)
                                                
                                                Text("Recommended Rest: \(currentExercises[currentExerciseIndex].rest) seconds")
                                                Spacer()
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                    .padding([.horizontal, .bottom])

                                    ForEach(0 ..< currentExerciseData.count, id: \.self) { index in
                                        ExerciseDataWidget(exerciseDataWidgetModel: $currentExerciseData[index], index: index, onStartSet: $onStartSet, onDataEntryComplete: $onDataEntryCompleteHandler)
                                            .onAppear {
                                                onDataEntryCompleteHandler = { index in
                                                    addExerciseData(index: index)
                                                }
                                                onStartSet = { index in
                                                    stopPreviousRestTimer(index: index)
                                                }
                                            }
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .padding(.top)
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
                    currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, clear: false, stopRestTimer: false))
                } else {
                    currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: false, isStarted: false, clear: false, stopRestTimer: false))
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
            currentExerciseData[index + 1] = ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, clear: false, stopRestTimer: false)
        }
        else {
            withAnimation {
                stopPreviousRestTimer(index: currentExerciseData.count)
                
                currentExercises[currentExerciseIndex].completed = true
                
                if let dayIndex = storageManager.program?.program.firstIndex(where: { $0.day == programWorkoutManager.getCurrentWeekday() }) {
                    storageManager.program?.program[dayIndex].exercises = currentExercises
                    
                    storageManager.program?.program[dayIndex].exercises[currentExerciseIndex].data = getAllExerciseDatas()

                }
                
//                if currentExerciseIndex < currentExercises.count - 1 {
//                    currentExerciseIndex += 1
//                }
                
                resetFields()
            }
        }
    }
    
    func getAllExerciseDatas() -> [ExerciseData] {
        let exerciseDataArray = currentExerciseData.map { ExerciseData(from: $0) }
        return exerciseDataArray
    }
    
    func stopPreviousRestTimer(index: Int) {
        guard index > 0 && index - 1 < currentExerciseData.count else {
               print("Index \(index) out of bounds for stopPreviousRestTimer")
               return
           }
        
        currentExerciseData[index - 1].stopRestTimer = true
    }
}


#Preview {
    WorkoutView(storageManager: StorageManager(), onStartSet: { int1 in }, onDataEntryCompleteHandler: { int  in })
}

