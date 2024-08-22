//
//  ChallengeCompletedView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/22/24.
//

import SwiftUI

struct ChallengeCompletedView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack() {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow.opacity(0.3), radius: 5, x: 0, y: 2)
                    .padding(.bottom)
                
                Text("Challenge Completed!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text("Congratulations on finishing your Challenge!")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
            
                Spacer()
                
                VStack(spacing: 15) {
                    Text("+10 XP")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    
                    Text("for completion")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding(.bottom)
                
                Button(action: {
//                    Task {
////                        XPManager.shared.addXP(increment: 10, type: .total)
////                        await XPManager.shared.addXPToDB()
//                    }
                    dismiss()
                }) {
                    Text("Continue")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(25)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
            }
            .padding(.top, 75)
        }
    }
}

#Preview {
    ChallengeCompletedView()
}
