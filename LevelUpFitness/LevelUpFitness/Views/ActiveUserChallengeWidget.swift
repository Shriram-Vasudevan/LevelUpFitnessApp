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
                    
                    HStack {
                        ProgressView(value: Double(currentProgress), total: Double(challenge.targetValue))
                            .progressViewStyle(CustomProgressViewStyle())
                            .frame(height: 8)
                        
                        Text("\(currentProgress)/\(challenge.targetValue)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                    }
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
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue)
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: 8)
            }
        }
    }
}

#Preview {
    ActiveUserChallengeWidget(
        challenge: UserChallenge(
            userID: "user123",
            id: "challenge1",
            challengeTemplateID: "template1",
            name: "30-Day Fitness Challenge",
            startDate: "2024-08-01",
            endDate: "2024-08-30",
            startValue: 0,
            targetValue: 30,
            field: "days",
            isFailed: false,
            isActive: true
        ),
        currentProgress: 18
    )
}
