//
//  LevelCircularProgressView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import SwiftUI

struct LevelCircularProgressBar: View {
    var progress: Double
    var level: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 8)
            
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(Color.white, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(Angle(degrees: -90))
            
            Text("\(level)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    LevelCircularProgressBar(progress: 0.5, level: 2)
}
