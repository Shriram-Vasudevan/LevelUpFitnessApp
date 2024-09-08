//
//  JoinProgramWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/2/24.
//

import SwiftUI

struct JoinProgramWidget: View {
    var standardProgramDBRepresentation: StandardProgramDBRepresentation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(standardProgramDBRepresentation.name)
                .font(.system(size: 22, weight: .bold, design: .default))
                .foregroundColor(.black)
            
            HStack {
                programInfoItem(title: "Environment:", value: standardProgramDBRepresentation.environment)
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(Color(hex: "40C4FC"))
                    .font(.system(size: 24))
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(8)
    }
    
    private func programInfoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .ultraLight, design: .default))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .light, design: .default))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    JoinProgramWidget(standardProgramDBRepresentation: StandardProgramDBRepresentation(id: "vwerfwefegrw", name: "Masucle Maximization Program", environment: "Gym"))
}
