//
//  LibraryExerciseDataView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/25/24.
//

import SwiftUI

struct LibraryExerciseDataView: View {
    @State var sectionType: LibraryExerciseDataSectionType = .start
    
    @State var exerciseData: ExerciseData
    
    @State var numberOfSets: String = ""
    @State var setsFieldNotFilledOut: Bool = false
    
    @State var currentExerciseDataSetIndex: Int = 0
    
    var isWeight: Bool
    
    var body: some View {
        ZStack {
            VStack {
                switch sectionType {
                    case .start:
                        HStack {
                            Text("Sets")
                                 .font(.custom("Sailec Bold", size: 20))
                             
                             TextField("", text: $numberOfSets)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(setsFieldNotFilledOut ? Color.red : Color.black)
                                )
                                 .frame(width: 65)
                        }
                    
                        Button {
                            if !numberOfSets.isEmpty {
                                setsFieldNotFilledOut = false
                                
                                initializeExerciseData(numberOfSets: numberOfSets)
                                
                                sectionType = .inProgress
                            } else {
                                setsFieldNotFilledOut = true
                            }
                        } label: {
                            Text("Begin Sets")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .cornerRadius(7)
                                .shadow(radius: 3)
                                .padding(.horizontal, 20)
                                .padding(.vertical)
                                .padding(.bottom)
                        }
                    case .inProgress:
                        ForEach(exerciseData.sets.indices, id: \.self) { index in
                            LibraryExerciseDataSetWidget(exerciseDataSet: $exerciseData.sets[index], isWeight: isWeight, moveToNextSet: {
                                if !(index == exerciseData.sets.count - 1) {
                                    currentExerciseDataSetIndex += 1
                                } else {
                                    sectionType = .finished
                                }
                            })
                            .disabled(currentExerciseDataSetIndex == index ? false : true)
                            .padding()
                            .overlay (
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(currentExerciseDataSetIndex == index ? .black : .white, lineWidth: 2)
                            )
                            .padding()
                        }
                    case .finished:
                        Text("Complete!")
                        
                    Button {
                        self.exerciseData = ExerciseData(sets: [])
                        
                        sectionType = .start
                    } label: {
                        Text("Restart")
                    }

                }
            }
        }
    }
    
    func initializeExerciseData(numberOfSets: String) {
        guard let numSets = Int(numberOfSets) else { return }
        
        self.exerciseData = ExerciseData(sets: [])
        
        for _ in 0 ..< numSets {
            self.exerciseData.sets.append(ExerciseDataSet(weight: 0, reps: 0, time: 0.0, rest: 0.0))
        }
        
    }
}

struct LibraryExerciseDataSetWidget: View {
    @Binding var exerciseDataSet: ExerciseDataSet
    
    @State var weightText: String = ""
    @State var repText: String = ""
    
    
    @State var weightFieldNotFilledOut: Bool = false
    @State var repsFieldNotFilledOut: Bool = false
    
    @State var isWeight: Bool
    
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    @State var exerciseTime: Double = 0.0
    @State var restTime: Double = 0.0
    
    @State var isExercising: Bool = false
    @State var isResting: Bool = false
    
    var moveToNextSet: () -> Void
    
    var body: some View {
        HStack {
            VStack {
               Text("Weight")
                    .font(.custom("Sailec Bold", size: 20))
                    .opacity(isWeight ? 1 : 0.7)
                
                TextField("", text: $weightText)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(weightFieldNotFilledOut ? Color.red : Color.black)
                    )
                    .opacity(isWeight ? 1 : 0.7)
                    .disabled(isWeight ? false : true)
                    .frame(width: 65)
            }
            
            Spacer()
            
            VStack {
                Text("Reps")
                     .font(.custom("Sailec Bold", size: 20))
                 
                 TextField("", text: $repText)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(repsFieldNotFilledOut ? Color.red : Color.black)
                    )
                     .frame(width: 65)
            }
            
            Spacer()
            
            Text("\(exerciseTime)")
            
            Spacer()
            
            Text("\(restTime)")
            
            Spacer()
            
            if !isExercising && !isResting {
                Button {
                    startTimer(for: "time")
                    isExercising = true
                } label: {
                    Text("next")
                }

            } else if isExercising {
                Button {
                    stopTimer()
                    isExercising = false
                    isResting = true
                    startTimer(for: "rest")
                } label: {
                    Text("next")
                }
            } else if isResting && !isExercising {
                Button {
                    if (!weightText.isEmpty && isWeight && !repText.isEmpty) || (!repText.isEmpty && !isWeight) {
                        repsFieldNotFilledOut = false
                        weightFieldNotFilledOut = false
                        stopTimer()
                        isResting = false
                        nextSet()
                    }
                    else {
                        if weightText.isEmpty && isWeight {
                            weightFieldNotFilledOut = true
                        }
                        
                        repsFieldNotFilledOut = true
                    }
                } label: {
                    Text("next")
                }
            }

            Spacer()
        }
        .padding(.horizontal)
    }
    
    func nextSet() {
        let weight = Int(weightText) ?? 0
        let reps = Int(repText) ?? 0
        let exerciseTime = exerciseTime
        let restTime = restTime
        
        exerciseDataSet.weight = weight
        exerciseDataSet.reps = reps
        exerciseDataSet.time = exerciseTime
        exerciseDataSet.rest = restTime
        
        moveToNextSet()
    }
    
    func startTimer(for type: String) {
        elapsedTime = 0.0
        
        if type == "time" {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                elapsedTime += 0.1
                exerciseTime = elapsedTime
            })
        } else if type == "rest" {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                elapsedTime += 0.1
                restTime = elapsedTime
            })
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    LibraryExerciseDataView(exerciseData: ExerciseData(sets: []), isWeight: false)
}
