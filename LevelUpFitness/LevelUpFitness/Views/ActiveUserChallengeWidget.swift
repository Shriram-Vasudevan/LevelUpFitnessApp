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
            Text(formattedChallengeName(challenge.name))
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(.black)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            HStack {
                ProgressView(value: Double(currentProgress), total: Double(challenge.targetValue))
                    .progressViewStyle(CustomProgressViewStyle())
                    .frame(height: 4)
                
                Text("\(currentProgress)/\(challenge.targetValue)")
                    .font(.system(size: 14, weight: .medium, design: .default))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .frame(width: UIScreen.main.bounds.width / 2 - 20, height: 100)
        .background(Color(hex: "F5F5F5"))
        .overlay(
            Rectangle()
                .fill(Color(hex: "40C4FC"))
                .frame(width: 4)
                .padding(.vertical, 16),
            alignment: .leading
        )
    }
    
    func formattedChallengeName(_ name: String) -> String {
        return name
    }
}

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color(hex: "40C4FC"))
                    .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * geometry.size.width, height: 4)
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
