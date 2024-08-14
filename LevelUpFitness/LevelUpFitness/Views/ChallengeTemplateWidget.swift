//
//  ChallengeTemplateWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/13/24.
//

import SwiftUI

struct ChallengeTemplateWidget: View {
    var challenge: ChallengeTemplate
    
    var challengeSelected: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Button(action: {
                challengeSelected()
            }) {
                Text("Start")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .cornerRadius(20)
            }
            
            HStack {
                Spacer()
                
                Text("Recommended Exercise")
                    .font(.caption)
                    .foregroundColor(.white)
            }
            .padding(.top, -20)
        }
        .padding([.horizontal, .top], 20)
        .background(
            LinearGradient(gradient: Gradient(colors: [
                Color(red: 0.4, green: 0.2, blue: 0.7),
                Color(red: 0.2, green: 0.3, blue: 0.8)
            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ChallengeTemplateWidget(challenge: ChallengeTemplate(id: "", name: "", description: "", duration: 5, targetField: ""), challengeSelected: {})
}
