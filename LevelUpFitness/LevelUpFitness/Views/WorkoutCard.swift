//
//  WorkoutCard.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct WorkoutCard: View {
    @State var workout: Workout
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text(workout.title)
                    .font(.custom("Sailec Bold", size: 25))
                    .padding(.bottom, 2)
                
                Spacer()
                
                Text(workout.isPaid ? "Paid" : "Not Paid")
            }
            
            HStack {
                Text("\(workout.date) | \(workout.trainer)")
                    .font(.system(size: 15))
                
                Spacer()
            }
            
            Text(workout.location)
                
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.white)
                .stroke(.black, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    WorkoutCard(workout: Workout(id: UUID().uuidString, title: "Weekly Training", date: "May 27, 2024", trainer: "Luke Nappi", location: "76 Street Lane", isPaid: false))
}
