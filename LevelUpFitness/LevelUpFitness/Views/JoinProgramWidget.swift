//
//  JoinProgramWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/2/24.
//

import SwiftUI

struct JoinProgramWidget: View {
    var programName: String
    var body: some View {
        Image("GuyAtTheGym")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(10)
            .padding()
            .blur(radius: 2)
            .brightness(-0.5)
            .overlay (
                VStack {
                    Text(programName)
                        .font(.custom("EtruscoNowCondensed Bold", size: 30))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .blue, radius: 5, x: 5, y: 5)
                }
                .padding()
                
            )
    }
}

#Preview {
    JoinProgramWidget(programName: "Program")
}
