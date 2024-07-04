//
//  ExerciseDataWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/4/24.
//

import SwiftUI

struct ExerciseDataWidget: View {
    @State var weightText: String = ""
    @State var repText: String = ""
    
    @State var timeText: String = ""
    @State var restText: String = ""
    
    @Binding var exerciseDataWidgetModel: ExerciseDataWidgetModel
    
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    var index: Int

    @FocusState private var isWeightTextFieldFocused: Bool
    
    @Binding var repComplete: (Int) -> Void
    @Binding var lastRepComplete: () -> Void
    
    var body: some View {
        VStack (spacing: 0) {
            if exerciseDataWidgetModel.isAvailable && !exerciseDataWidgetModel.isStarted {
                HStack {
                    Text("Weight: ")
                        .bold()
                        .padding(.leading, 70)
                    TextField("", text: $weightText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
    //                        .keyboardType(.numberPad)
                        .focused($isWeightTextFieldFocused)
                    
                    Spacer()
                }
                .padding()
                
                HStack {
                    Spacer()
                    
                    Text("Reps: ")
                        .bold()
                    TextField("", text: $repText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                        .multilineTextAlignment(.center)
    //                        .keyboardType(.numberPad)
                        .focused($isWeightTextFieldFocused)
                        .padding(.trailing, 70)
                }
                .padding()
                
                Button {
                    exerciseDataWidgetModel.isStarted = true
                   
                    print("the index: \(exerciseDataWidgetModel.isStarted)")
                    
                    startTimer(for: "time")
                } label: {
                    Text("Start")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(7)
                        .shadow(radius: 3)
                        .padding(.horizontal, 20)
                        .padding(.vertical)
                }
            } else if exerciseDataWidgetModel.isStarted && exerciseDataWidgetModel.isAvailable {
                
                Text(timeText)
                    .font(.custom("EtruscoNowCondensed Bold", size: 40))
        
                
                Button {
                    stopTimer()
                    exerciseDataWidgetModel.isAvailable = false
                    startTimer(for: "rest")
                } label: {
                    Text("Start Rest")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(7)
                        .shadow(radius: 3)
                        .padding(.horizontal, 20)
                        .padding(.vertical)
                }
            }
            else if exerciseDataWidgetModel.isResting && exerciseDataWidgetModel.isAvailable {
                
                Text(restText)
                    .font(.custom("EtruscoNowCondensed Bold", size: 40))
        
                
                Button {
                    stopTimer()
                    exerciseDataWidgetModel.isAvailable = false
                    saveAllData()
                } label: {
                    Text(exerciseDataWidgetModel.isLast ? "Next Exercise" : "Next Rep")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .cornerRadius(7)
                        .shadow(radius: 3)
                        .padding(.horizontal, 20)
                        .padding(.vertical)
                }
                
            }
        }
    }
    
    func saveAllData() {
        let weightValue = Int(weightText) ?? 0
        let timeValue = Double(timeText) ?? 0.0
        let restValue = Double(restText) ?? 0.0

        print("assigning val")
        exerciseDataWidgetModel.weight = weightValue
        exerciseDataWidgetModel.time = timeValue
        exerciseDataWidgetModel.rest = restValue
        exerciseDataWidgetModel.isAvailable = false
        exerciseDataWidgetModel.isStarted = false
        exerciseDataWidgetModel.stopRestTimer = false

        if exerciseDataWidgetModel.isLast {
            lastRepComplete()
            exerciseDataWidgetModel.isLast = false
        }
        else {
            repComplete(index)
        }

    }
    func startTimer(for type: String) {
        elapsedTime = 0.0
        
        if type == "time" {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                elapsedTime += 0.1
                timeText = String(format: "%.1f", elapsedTime)
            })
        } else if type == "rest" {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { _ in
                elapsedTime += 0.1
                restText = String(format: "%.1f", elapsedTime)
            })
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    ExerciseDataWidget(exerciseDataWidgetModel: .constant(ExerciseDataWidgetModel(weight: 0, reps: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, isResting: false, stopRestTimer: false, clear: false, isLast: false)), index: 0, repComplete: .constant({_ in }), lastRepComplete: .constant({}))
}
