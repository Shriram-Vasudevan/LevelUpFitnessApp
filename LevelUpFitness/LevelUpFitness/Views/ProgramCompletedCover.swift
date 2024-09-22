//
//  ProgramCompletedCover.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/21/24.
//

import SwiftUI

struct ProgramCompletedCover: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(hex: "40C4FC"))
                    .shadow(color: Color(hex: "40C4FC").opacity(0.3), radius: 5, x: 0, y: 2)
                
                VStack(spacing: 6) {
                    Text("Program Completed!")
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.black)
                    
                    Text("Congratulations on finishing your fitness program!")
                        .font(.system(size: 16, weight: .light, design: .default))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
                
                VStack(spacing: 8) {
                    Text("+15 XP")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(Color(hex: "40C4FC"))
                    
                    Text("for completion")
                        .font(.system(size: 14, weight: .ultraLight, design: .default))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(hex: "F5F5F5"))
                .cornerRadius(8)
                
                Button(action: {
                    XPManager.shared.addXP(increment: 15, type: .total)
                    dismiss()
                }) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "40C4FC"))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding(.top, 75)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    ProgramCompletedCover()
}
