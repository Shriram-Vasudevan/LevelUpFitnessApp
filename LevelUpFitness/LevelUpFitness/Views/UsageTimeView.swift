//
//  UsageTimeView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct UsageTimeView: View {
    var usageTime: String
    var usagePercentage: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 30, height: 200)

                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.green)
                    .frame(width: 30, height: 200 * usagePercentage)
            }
            
            Text(usageTime)
                .foregroundColor(.black)
                .font(.caption)
        }
        .frame(width: 50)
    }
}

#Preview {
    UsageTimeView(usageTime: "40", usagePercentage: 0.7)
}
