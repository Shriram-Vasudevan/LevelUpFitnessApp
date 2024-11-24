//
//  FutureWorkoutOverlays.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 11/23/24.
//

import SwiftUI

struct FutureWorkoutOverlay: View {
    let date: Date
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
            
            VStack(spacing: 16) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                
                Text("Workout Available in")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Text(date.formatted(.relative(presentation: .named)))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(hex: "40C4FC"))
            }
        }
        .ignoresSafeArea()
    }
}
