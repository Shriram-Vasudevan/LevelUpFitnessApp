//
//  ProgramStatisticsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/8/24.
//

import SwiftUI
import Charts

struct ProgramStatisticsView: View {
    @State var program: Program
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        })
                        
                        Text("Close")
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        
                        Text("Metrics")
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
              
                }
                
                VStack {
                    
                    ScrollView(.vertical) {
                        Group {
                            HStack {
                                ProgramCircularProgressBar(progress: program.getProgramCompletionPercentage())
                                    .frame(width: 50, height: 50)
                                    .padding(.vertical)
                                    .padding(.trailing, 5)
                                
                                VStack(alignment: .leading) {
                                    Text("Percentage of Program")
                                        .font(.headline)
                                    Text("completed this week")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Here's the Breakdown")
                                    .font(.headline)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            Chart {
                                ForEach(program.getDayCompletionPercentages()) { kvp in
                                    
                                    BarMark(
                                       x: .value("Date", kvp.day),
                                       y: .value("Percentage", kvp.percentage)
                                   )
                                }
                            }
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .chartYScale(domain: 0...100)
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                        
                        VStack (spacing: 0) {
                            HStack {
                                Text("Rest Metrics")
                                    .font(.title3)
                                    .bold()
                                
                                Spacer()
                            }
                            .padding()
                            
                            RestDistributionBar(restTime: program.getTotalRestTime(), workoutTime: program.getTotalWorkoutTime())
                                .padding(.bottom)
      
                            HStack {
                                VStack {
                                    Text("\(String(format: "%.1f", program.getAverageRestDifferential())) s")
                                    Text("Avg. Rest Differential")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)

                                Divider()

                                VStack {
                                    Text("\(String(format: "%.1f", program.getTotalWorkoutTime())) s")
                                    Text("Total Workout Time")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)

                                Divider()

                                VStack {
                                    Text("\(String(format: "%.1f", program.getTotalRestTime())) s")
                                    Text("Total Rest Time")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            

                        }
                        Spacer()
                    }
                }
                .padding(.top, 7)
                .background(
                    Rectangle()
                        .fill(.white)
                )
                .ignoresSafeArea(.all)
            }
            
            
        }
    }
}

struct ProgramCircularProgressBar: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 5.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress / 100, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)

            Text(String(format: "%.0f%%", min(self.progress, 100.0)))
                .font(.headline)
                .bold()
        }
    }
}

struct RestDistributionBar: View {
    var restTime: Double
    var workoutTime: Double

    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                HStack {
                    Rectangle()
                        .fill(.green)
                        .frame(width: 10, height: 10)
                    
                    Text("Rest")
                    
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 10, height: 10)
                    
                    Text("Workout")
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                GeometryReader { reader in
                    RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(height: 40)
                                .frame(maxWidth: reader.size.width)
                                .padding(.horizontal)
                    
                            Rectangle()
                                .fill(Color.green)
                                .frame(height: 40)
                                .frame(maxWidth: reader.size.width * restTime / (workoutTime + restTime))
                                .padding(.horizontal)
                }
                .frame(height: 40)
            }

        }
    }
}

#Preview {
    ProgramStatisticsView(program: Program(program: [ProgramDay(day: "Monday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, completed: false, data: [ExerciseData(from: ExerciseDataWidgetModel(weight: 2, time: 8.0, rest: 5.0, isAvailable: false, isStarted: false, clear: false, stopRestTimer: false))])])], programName: "program"))
}
