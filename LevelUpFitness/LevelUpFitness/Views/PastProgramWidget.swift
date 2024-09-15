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
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.black)
                    Text("Tap to view details")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
        }
    }
}


#Preview {
    PastProgramWidget(programUnformatted: "Original", programFormatted: "Program: August 22 - September 19", viewPastProgram: {_ in })
}
