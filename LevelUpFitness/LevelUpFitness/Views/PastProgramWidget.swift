//
//  PastProgramWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/23/24.
//

import SwiftUI

struct PastProgramWidget: View {
    var programUnformatted: String
    var programFormatted: String
    
    var viewPastProgram: (String) -> Void
    
    var body: some View {
        VStack {
            HStack () {
                Text(programFormatted)
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            
            HStack {
                Spacer()
                
                Button {
                    viewPastProgram(programUnformatted)
                } label: {
                    Text("See More")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(20)
                }

            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .shadow(radius: 5)
        )
        .padding()
    }
}

#Preview {
    PastProgramWidget(programUnformatted: "Original", programFormatted: "Program: August 22 - September 19", viewPastProgram: {_ in })
}
