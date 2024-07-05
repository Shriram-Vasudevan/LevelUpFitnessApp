//
//  ExerciseDataSetWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/5/24.
//

import SwiftUI

struct ExerciseDataSetWidget: View {
    @Binding var model: ExerciseDataSet
    
    @State var isExercising: Bool = false
    @State var isResting: Bool = false
    @State var isLastSet: Bool
    
    var setIndex: Int
    
    @State var timer: Timer?
    @State var elapsedTime: Double = 0.0
    
    @State var timeText: String = "0.0"
    @State var restText: String = "0.0"
    
    @State var weightText: String = ""
    @State var repText: String = ""
    
    @Binding var setCompleted: () -> Void
    @Binding var lastSetCompleted: () -> Void
    
    var body: some View {
        VStack  {
            HStack {
                Text("Set \(setIndex + 1)")
                    .font(.custom("EtruscoNowCondensed Bold", size: 35))
                
                Spacer()
            }
            
            HStack {
                Text("Weight: ")
                    .bold()
                TextField("", text: $weightText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            
            HStack {
                Text("Reps: ")
                    .bold()
                TextField("", text: $repText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.bottom)
            
            if !isExercising && !isResting {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5.0)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: 360.0)
                        .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear)
                    
                    Text("\(timeText)")
                        .font(.custom("EtruscoNowCondensed Bold", size: 65))
                }
                .frame(width: 175, height: 175)
                
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
                }
            }
            else if isExercising {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5.0)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: 360.0)
                        .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear)
                    
                    Text("\(timeText)")
                        .font(.custom("EtruscoNowCondensed Bold", size: 65))
                }
                .frame(width: 175, height: 175)
                
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
                }
            }
            else if isResting && !isExercising {
                ZStack {
                    Circle()
                        .stroke(lineWidth: 5.0)
                        .opacity(0.3)
                        .foregroundColor(Color.blue)

                    Circle()
                        .trim(from: 0.0, to: 360.0)
                        .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear)

                    Text("\(timeText)")
                        .font(.custom("EtruscoNowCondensed Bold", size: 65))
                }
                .frame(width: 175, height: 175)
                
                Button {
                    stopTimer()
                    isResting = false
                    saveData()
                    isLastSet ? lastSetCompleted() : setCompleted()
                } label: {
                    Text(isLastSet ? "Next Exercise" : "Next Set")
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
        .padding()
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
    ExerciseDataSetWidget(model: .constant(ExerciseDataSet(weight: 10, reps: 5, time: 0.0, rest: 0.0)), isLastSet: false, setIndex: 0, setCompleted: .constant({}), lastSetCompleted: .constant({}))
}
