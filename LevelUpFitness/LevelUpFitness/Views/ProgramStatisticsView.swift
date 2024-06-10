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
                                CircularProgressBar(progress: program.getProgramCompletionPercentage())
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
                            .frame(height: 200)
                            .padding(.horizontal)
                        }
                        
                        Group {
                            HStack {
                                Text("Rest Metrics")
                                    .font(.title3)
                                    .bold()
                                    .padding(.top)
                                
                                Spacer()
                            }
                            .padding(.horizontal)
                            
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
                                    Text("\(String(format: "%.1f", program.getAverageRestDifferential())) s")
                                    Text("Avg. Rest Differential")
                                        .font(.headline)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)

                                Divider()

                                VStack {
                                    Text("\(String(format: "%.1f", program.getAverageRestDifferential())) s")
                                    Text("Avg. Rest Differential")
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

struct CircularProgressBar: View {
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


#Preview {
    ProgramStatisticsView(program: Program(program: [ProgramDay(day: "Monday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, completed: false, data: [ExerciseData(from: ExerciseDataWidgetModel(weight: 2, time: 2.0, rest: 5.0, isAvailable: false, isStarted: false, clear: false, stopRestTimer: false))])])], programName: "program"))
}
