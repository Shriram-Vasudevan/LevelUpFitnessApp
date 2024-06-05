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
    
    @Binding var onDataEntryComplete: ((String, String, String) -> Void)
    
    var body: some View {
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
            
            Button {
                onDataEntryComplete(weightText, timeText, restText)
            } label: {
                Text("Done")
            }

            
        }
        .padding()
    }
}

#Preview {
    ExerciseDataWidget(onDataEntryComplete: .constant({ string1, string2, string3 in }))
}
