//
//  WeightStatView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/31/24.
//

import SwiftUI

struct WeightStatView: View {
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
//                        Image(systemName: imageName)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 20, height: 20)
//                            .foregroundColor(.black)
                        
                        Text("Weight")
                            .font(.title3)
                            .foregroundColor(.black)
                            .bold()
                    }
                   
                    Text("See or View your Weight Trend")
                }
                
                Spacer()
                
                Image("TrendBlue")
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding()
    }
}

#Preview {
    WeightStatView()
}
