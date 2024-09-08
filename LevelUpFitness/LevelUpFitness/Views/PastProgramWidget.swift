//
//  PastProgramWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/23/24.
//

import SwiftUI

struct PastProgramWidget: View {
    let programUnformatted: String
    let programFormatted: String
    let viewPastProgram: (String) -> Void
    
    var body: some View {
        Button(action: { viewPastProgram(programUnformatted) }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(programFormatted)
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.black)
                    Text("Tap to view details")
                        .font(.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color(hex: "40C4FC"))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}


#Preview {
    PastProgramWidget(programUnformatted: "Original", programFormatted: "Program: August 22 - September 19", viewPastProgram: {_ in })
}
