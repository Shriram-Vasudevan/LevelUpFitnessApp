//
//  WeightStatView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/31/24.
//

import SwiftUI

struct WeightStatView: View {
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Text("See or View your Weight Trend")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image("TrendBlue")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(Color(hex: "40C4FC"))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "F5F5F5"))
    }
}

#Preview {
    WeightStatView()
}
