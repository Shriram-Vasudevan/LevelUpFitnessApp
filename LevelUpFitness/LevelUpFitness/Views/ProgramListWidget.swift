//
//  ProgramListWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/27/24.
//

import SwiftUI

struct ProgramListWidget: View {
    @ObservedObject var storageManager: StorageManager
    
    @Binding var navigateToWorkoutView: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(getCurrentWeekday())
                    .font(.title)
                    .bold()
                
                Spacer()
                
            }
            
            Divider()
                .padding(.bottom, 5)
            
            ZStack {
                Image("ManExercising - PushUp")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                if let todaysProgram = storageManager.program?.program.first(where: { $0.day == getCurrentWeekday() }) {
                    VStack(spacing: 5) {
                        ForEach(todaysProgram.exercises, id: \.name) { exercise in
                            HStack {
                                Text("\(exercise.name)")
                                
                                Spacer()
                                
                                if exercise.completed {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                } else {
                    Text("No program for today")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(.white)
                .shadow(radius: 5)
        )
        .padding(.horizontal)
        .padding(.bottom)
        .onTapGesture {
            navigateToWorkoutView = true
        }
    }
    
    func getCurrentWeekday() -> String {
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: date)
        
        return weekday
    }
}

#Preview {
    ProgramListWidget(storageManager: StorageManager(), navigateToWorkoutView: .constant(false))
}
