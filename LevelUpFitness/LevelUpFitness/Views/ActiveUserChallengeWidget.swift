//
//  ActiveUserChallengeWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/14/24.
//

import SwiftUI

struct ActiveUserChallengeWidget: View {
    var challenge: UserChallenge
    var currentProgress: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
//                    Text(challenge.description)
//                        .font(.system(size: 12, weight: .medium, design: .rounded))
//                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.7))
            }

        }
        .padding(20)
        .background(
            LinearGradient(gradient: Gradient(colors: [
                        Color(red: 0.678, green: 0.847, blue: 0.902),
                        Color(red: 0.565, green: 0.933, blue: 0.565)
                    ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ActiveUserChallengeWidget(challenge: UserChallenge(userID: "", id: "", challengeTemplateID: "", name: "", startDate: "", endDate: "", startValue: 1, targetValue: 1, field: "", isFailed: false, isActive: false), currentProgress: 3)
}
