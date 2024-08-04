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
//            Circle()
//                .stroke(lineWidth: 5.0)
//                .opacity(0.3)
//                .foregroundColor(Color.blue)

            Circle()
                .fill(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))

            Text("\(level)")
                .font(.custom("EtruscoNowCondensed Bold", size: 40))
                .foregroundColor(.white)
                .bold()
                .scaledToFill()
        }
    }
}

#Preview {
    LevelCircularProgressBar(progress: 0.5, level: 2)
}
