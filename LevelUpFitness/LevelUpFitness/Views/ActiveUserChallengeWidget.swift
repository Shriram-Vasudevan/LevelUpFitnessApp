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
        RoundedRectangle(cornerRadius: 10)
            .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 6)
            .overlay(
                Image("GuyAtTheGym")
                    .resizable()
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.height / 6)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        Color.black.opacity(0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    )
            )
            .overlay(
                Text(formattedChallengeName(challenge.name))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(7),
                alignment: .topLeading
            )
            .overlay (
                Text("\(currentProgress)/\(challenge.targetValue)")
                    .foregroundColor(.white)
                    .padding(),
                alignment: .bottomTrailing
            )

//        
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(formattedChallengeName(challenge.name))
//                                            .font(.system(size: 22, weight: .bold, design: .rounded))
//                                            .foregroundColor(.white)
//                    
////                    HStack {
////                        ProgressView(value: Double(currentProgress), total: Double(challenge.targetValue))
////                            .progressViewStyle(CustomProgressViewStyle())
////                            .frame(height: 8)
////                        
////                        Text("\(currentProgress)/\(challenge.targetValue)")
////                            .font(.system(size: 14, weight: .semibold, design: .rounded))
////                            .foregroundColor(.white.opacity(0.9))
////                    }
//                }
//
//            }
//        }
//        .padding(20)
//        .background(
//            Image("GuyAtTheGym")
//        )
//        .cornerRadius(10)
//        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
//        .padding()
    }
    
    func formattedChallengeName(_ name: String) -> String {
        var words = name.split(separator: " ")
        guard let lastWord = words.popLast() else { return name }
        return words.joined(separator: " ") + "\n" + lastWord
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
