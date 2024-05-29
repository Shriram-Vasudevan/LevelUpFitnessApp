//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import SwiftUI

struct ProgramView: View {
    @State var program: Program
    
    @State var navigateToWorkoutView: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack (spacing: 0) {
                HStack {
                    Button(action: {
                        dismiss()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    })
                    
                    Text("Exit")
                    
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack {
                    Text("Today's Program")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                    
                    Spacer()
                }
                .padding([.horizontal, .bottom])
                
                ProgramListWidget(navigateToWorkoutView: $navigateToWorkoutView, program: program)
                
                
                HStack {
                    Text("Bonus Exercises")
                        .font(.custom("EtruscoNowCondensed Bold", size: 35))
                    
                    Spacer()
                }
                .padding([.horizontal, .bottom])
                Spacer()
                
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ProgramView(program: Program(program: [ProgramDay(day: "", workout: "", completed: false, exercises: [Exercise(name: "", sets: "", reps: "", rpe: "", rest: 0, completed: false)])]))
}
