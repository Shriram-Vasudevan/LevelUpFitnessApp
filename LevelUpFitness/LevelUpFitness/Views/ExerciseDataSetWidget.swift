//
//  ExerciseDataSetWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/5/24.
//

import SwiftUI


struct ProramExerciseDataSetWidget: View {
    @Binding var model: ExerciseDataSet
    
    @State var isExercising: Bool = false
    @State var isResting: Bool = false
    
    var setIndex: Int
    
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    @State var timeText: String = "0.0"
    @State var restText: String = "0.0"
    
    @State var weightText: String = ""
    @State var repText: String = ""
    
    @State var setCompleted: () -> Void
    
    @State var weightFieldNotFilledOut: Bool = false
    @State var repsFieldNotFilledOut: Bool = false
    
    @State var isWeight: Bool
    
    var body: some View {
        VStack {
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
                
                Text("X")
                
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
            }
            .padding(.horizontal, 50)

            Spacer()
            
            if !isExercising && !isResting {
                ZStack {
                    Text("\(timeText)")
                        .font(.custom("EtruscoNowCondensed Bold", size: 40))
                        .bold()

                }
            }
            else if isExercising {
                ZStack {
                    Text("\(timeText)")
                        .font(.custom("EtruscoNowCondensed Bold", size: 40))
                        .bold()

                }
            } else if isResting && !isExercising {
                ZStack {
                    Text("\(restText)")
                        .font(.custom("EtruscoNowCondensed Bold", size: 40))
                        .bold()
                    
                }
            }
            
            if !isExercising && !isResting {
                Button {
                    startTimer(for: "time")
                    isExercising = true
                } label: {
                    Text("Begin Reps")
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
            }
            else if isExercising {
                Button {
                    stopTimer()
                    isExercising = false
                    isResting = true
                    startTimer(for: "rest")
                } label: {
                    Text("Begin Rest")
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
            }
            else if isResting && !isExercising {
                Button {
                    if (!weightText.isEmpty && isWeight && !repText.isEmpty) || (!repText.isEmpty && !isWeight) {
                        repsFieldNotFilledOut = false
                        weightFieldNotFilledOut = false
                        stopTimer()
                        isResting = false
                        saveData()
                        setCompleted()
                    }
                    else {
                        if weightText.isEmpty && isWeight {
                            weightFieldNotFilledOut = true
                        }
                        
                        repsFieldNotFilledOut = true
                    }
                } label: {
                    Text("Continue")
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
            }
        }
    }
    
    func saveData() {
        let weightValue = Int(weightText) ?? 0
        let repsValue = Int(repText) ?? 0
        let timeValue = Double(timeText) ?? 0.0
        let restValue = Double(restText) ?? 0.0
        
        model.weight = weightValue
        model.reps = repsValue
        model.time = timeValue
        model.rest = restValue
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
    ProramExerciseDataSetWidget(model: .constant(ExerciseDataSet(weight: 10, reps: 5, time: 0.0, rest: 0.0)), setIndex: 0, setCompleted: {}, isWeight: false)
}
