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
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(programFormatted)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color(hex: "111827"))
                    Text("Open program insight report")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "0B5ED7"))
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}


#Preview {
    PastProgramWidget(programUnformatted: "Original", programFormatted: "Program: August 22 - September 19", viewPastProgram: {_ in })
}
