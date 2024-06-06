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
    
    var index: Int
    
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
                
                Text("Rest: ")
                TextField("", text: $restText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 50)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
            }
            .padding()
            
            if exerciseDataWidgetModel.isAvailable {
                Button {
                    exerciseDataWidgetModel.isAvailable = false
                    exerciseDataWidgetModel.isStarted = true
                } label: {
                    Text("Start")
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
            } else if exerciseDataWidgetModel.isStarted {
                Button {
                    onDataEntryComplete(weightText, timeText, restText, index)
                } label: {
                    Text("Finish")
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
        }
    }
}

#Preview {
    ExerciseDataWidget(exerciseDataWidgetModel: .constant(ExerciseDataWidgetModel(weight: 0, time: 0.0, rest: 0.0, isAvailable: false, isStarted: false)), index: 0, onDataEntryComplete: .constant({ string1, string2, string3, int in }))
}
