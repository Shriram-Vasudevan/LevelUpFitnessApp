//
//  ProgramView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/26/24.
//

import SwiftUI

struct ProgramView: View {
    @State var program: Program
    
    var body: some View {
        ZStack {
            VStack {
                
            }
        }
    }
}

#Preview {
    ProgramView(program: Program(program: [ProgramDay(day: "", workout: "", completed: false, exercises: [Exercise(name: "", sets: "", reps: "", rpe: "", rest: 0, completed: false)])]))
}
