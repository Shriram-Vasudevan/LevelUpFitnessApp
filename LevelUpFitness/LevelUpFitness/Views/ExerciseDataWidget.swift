//
//  ExerciseDataWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/4/24.
//

import SwiftUI

struct ExerciseDataWidget: View {
    @State var weightText: String = ""
    @State var timeText: String = ""
    @State var restText: String = ""
    
    @Binding var exerciseDataWidgetModel: ExerciseDataWidgetModel
    
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    var index: Int
    
    @Binding var onStartSet: ((Int) -> Void)
    @Binding var onDataEntryComplete: ((String, String, String, Int) -> Void)
    
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                Text("Weight: ")
                TextField("", text: $weightText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                
                Text("Time: ")
                TextField("", text: $timeText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .disabled(true)
                
                Text("Rest: ")
                TextField("", text: $restText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .disabled(true)
            }
            .padding()
            
            if exerciseDataWidgetModel.isAvailable && !exerciseDataWidgetModel.isStarted {
                Button {
                    exerciseDataWidgetModel.isStarted = true
                    onStartSet(index)
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
                Button {
                    stopTimer()
                    onDataEntryComplete(weightText, timeText, restText, index)
                    exerciseDataWidgetModel.isAvailable = false
                    startTimer(for: "rest")
                } label: {
                    Text("Finish")
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
        .opacity(exerciseDataWidgetModel.isAvailable ? 1 : 0.5)
        .onChange(of: exerciseDataWidgetModel) { newValue in
            if newValue.stopRestTimer {
                stopTimer()
            }
            
            if newValue.clear {
                weightText = ""
                timeText = ""
                restText = ""
            }
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
    ExerciseDataWidget(exerciseDataWidgetModel: .constant(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: true, isStarted: false, clear: false, stopRestTimer: false)), index: 0, onStartSet: .constant({ int1 in}), onDataEntryComplete: .constant({ string1, string2, string3, int in }))
}
