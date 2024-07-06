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
    
    @State var exerciseName: String
    @State var exerciseReps: Int
    @State var numberOfSets: Int
    
    @State var exitWorkout: () -> Void
    var body: some View {
        VStack  {
            HStack {
                VStack (alignment: .center, spacing: 0) {
                    HStack {
                        Text(exerciseName)
                            .font(.custom("EtruscoNowCondensed Bold", size: 50))
                            .multilineTextAlignment(.center)
                            .padding(.bottom, -7)
                            .padding(.top, -10)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    HStack {
                        Text("Reps per Set: \(exerciseReps)")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.bottom)
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                SetCounterWidget(colorA: .blue, colorB: .cyan, stat: "\(setIndex + 1)", text: "of \(numberOfSets)", width: UIScreen.main.bounds.width / 6)
                    .padding(.bottom, 10)
            }
            .padding([.horizontal, .bottom])
            
            VStack {
                HStack {
                    VStack {
                       Text("Weight")
                            .font(.custom("Sailec Bold", size: 20))
                        
                        TextField("", text: $weightText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 65)
                    }
                    
                    Spacer()
                    
                    Text("X")
                    
                    Spacer()
                    
                    VStack {
                        Text("Reps")
                             .font(.custom("Sailec Bold", size: 20))
                         
                         TextField("", text: $repText)
                             .textFieldStyle(RoundedBorderTextFieldStyle())
                             .frame(width: 65)
                    }
                }
                .padding(.horizontal, 50)

                Spacer()
                
                if !isExercising && !isResting {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 5.0)
                            .opacity(0.3)
                            .foregroundColor(Color.blue)

                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.blue)
                            .rotationEffect(Angle(degrees: 270.0))

                        Text("\(timeText)")
                            .font(.custom("EtruscoNowCondensed Bold", size: 40))
                            .bold()

                    }
                    .frame(width: UIScreen.main.bounds.width / 1.3)
                }
                else if isExercising {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 5.0)
                            .opacity(0.3)
                            .foregroundColor(Color.blue)

                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.blue)
                            .rotationEffect(Angle(degrees: 270.0))
                            
                        
                        Text("\(timeText)")
                            .font(.custom("EtruscoNowCondensed Bold", size: 40))
                            .bold()

                    }
                    .frame(width: UIScreen.main.bounds.width / 1.3)
                } else if isResting && !isExercising {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 5.0)
                            .opacity(0.3)
                            .foregroundColor(Color.blue)
                        
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 10.0, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.blue)
                            .rotationEffect(Angle(degrees: 270.0))
                        
                        Text("\(restText)")
                            .font(.custom("EtruscoNowCondensed Bold", size: 40))
                            .bold()
                        
                    }
                    .frame(width: UIScreen.main.bounds.width / 1.3)
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
                            .padding(.bottom)
                    }
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
                
                Spacer()
                
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
    ExerciseDataSetWidget(model: .constant(ExerciseDataSet(weight: 10, reps: 5, time: 0.0, rest: 0.0)), isLastSet: false, setIndex: 0, setCompleted: .constant({}), lastSetCompleted: .constant({}), exerciseName: "Deadlift", exerciseReps: 10, numberOfSets: 10, exitWorkout: {})
}
