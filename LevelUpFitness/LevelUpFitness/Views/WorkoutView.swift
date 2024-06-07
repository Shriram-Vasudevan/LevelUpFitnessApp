//
//  WorkoutView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/28/24.
//

import SwiftUI

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
    @State var onDataEntryCompleteHandler: (String, String, String, Int) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.blue
                    .edgesIgnoringSafeArea(.all)
                
                if currentExercises.count > 0 {
                    VStack {
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
                            
                            Text("Workout")
                                .bold()
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: {
                                dismiss()
                                currentExerciseIndex = 0
                            }, label: {
                                Image(systemName: "xmark")
                                    .foregroundColor(.black)
                            })
                            .hidden()
                            
                            Text("Close")
                                .hidden()
                            
                        }
                        .padding(.horizontal)
                        
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
                                        Text("Reps per Set: \(currentExercises[currentExerciseIndex].reps)")
                                        Spacer()
                                    }
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    withAnimation {
                                        currentExercises[currentExerciseIndex].completed = true
                                        
                                        if let dayIndex = storageManager.program?.program.firstIndex(where: { $0.day == programWorkoutManager.getCurrentWeekday() }) {
                                            storageManager.program?.program[dayIndex].exercises = currentExercises
                                            
                                            storageManager.program?.program[dayIndex].exercises[currentExerciseIndex].data = getAllExerciseDatas()

                                        }
                                        
                                        if currentExerciseIndex < currentExercises.count - 1 {
                                            currentExerciseIndex += 1
                                        }
                                    }
                                }, label: {
                                    Text("Complete")
                                        .font(.footnote)
                                        .foregroundColor(.black)
                                        .bold()
                                        .padding()
                                        .background(
                                            Capsule()
                                                .fill(.green)
                                        )
                                })
                            }
                            .padding([.horizontal, .bottom])

                            ForEach(0 ..< currentExerciseData.count, id: \.self) { index in
                                ExerciseDataWidget(exerciseDataWidgetModel: $currentExerciseData[index], index: index, onStartSet: $onStartSet, onDataEntryComplete: $onDataEntryCompleteHandler)
                                    .onAppear {
                                        onDataEntryCompleteHandler = { weight, time, rest, index in
                                            addExerciseData(weight: weight, time: time, rest: rest, index: index)
                                        }
                                        onStartSet = { index in
                                            stopPreviousRestTimer(index: index)
                                        }
                                    }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                Task {
                                    await storageManager.uploadNewProgramStatus(completionHandler: {
                                        dismiss()
                                    })
                                }
                            }) {
                                Text("Save and Exit")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(minWidth: 0, maxWidth: .infinity)
                                    .padding()
                                    .background(.black)
                                    .cornerRadius(7)
                                    .shadow(radius: 3)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical)
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
                if let todaysProgram = storageManager.program?.program.first(where: { $0.day == programWorkoutManager.getCurrentWeekday() }) {
                    self.currentExercises = todaysProgram.exercises
                    
                    if let (index, _) = todaysProgram.exercises.enumerated().first(where: { $0.element.completed == false }) {
                        self.currentExerciseIndex = index
                    }
                    
                    currentExerciseData = []
                    for i in 0..<currentExercises[currentExerciseIndex].sets {
                        if i == 0 {
                            currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, stopRestTimer: false))
                        } else {
                            currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: false, isStarted: false, stopRestTimer: false))
                        }
                    }
                    
                    print("on appear \(currentExerciseData)")
                }
                else {
                    print("none")
                }
            }
            .onChange(of: currentExerciseIndex) { oldValue, newValue in
                currentExerciseData = []
                for i in 0..<currentExercises[currentExerciseIndex].sets {
                    if i == 0 {
                        currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, stopRestTimer: false))
                    } else {
                        currentExerciseData.append(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: false, isStarted: false, stopRestTimer: false))
                    }
                }
                
                print("on change \(currentExerciseData)")
            }
        }
    }
    
    func addExerciseData(weight: String, time: String, rest: String, index: Int) {
        let weightValue = Int(weight) ?? 0
        let timeValue = Double(time) ?? 0.0
        let restValue = Double(rest) ?? 0.0

        if index < currentExerciseData.count {
            currentExerciseData[index] = ExerciseDataWidgetModel(weight: weightValue, time: timeValue, rest: restValue, isAvailable: false, isStarted: false, stopRestTimer: false)
            
            print(currentExerciseData[index])
            print(index)
            print(currentExerciseData.count)
            
            if index + 1 < currentExerciseData.count {
                currentExerciseData[index + 1] = ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, stopRestTimer: false)
            }
        }
    }
    
    func getAllExerciseDatas() -> [ExerciseData] {
        let exerciseDataArray = currentExerciseData.map { ExerciseData(from: $0) }
        return exerciseDataArray
    }
    
    func stopPreviousRestTimer(index: Int) {
        if index > 0 {
            currentExerciseData[index - 1].stopRestTimer = true
        }
    }
}

#Preview {
    WorkoutView(storageManager: StorageManager(), onStartSet: { int1 in }, onDataEntryCompleteHandler: { string1, string2, string3, int  in })
}

