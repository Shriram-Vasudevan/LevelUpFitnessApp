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

    @State var showChallengeDetailsCover = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Challenge name and date range
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedChallengeName(challenge.name))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "333333"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text("\(formatDate(challenge.startDate)) - \(formatDate(challenge.endDate))")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "666666"))
                }
                Spacer()
                // Progress percentage circle
                ZStack {
                    Circle()
                        .stroke(Color(hex: "E0E0E0"), lineWidth: 4)
                        .frame(width: 50, height: 50)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(currentProgress) / CGFloat(challenge.targetValue))
                        .stroke(Color(hex: "40C4FC"), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int((Float(currentProgress) / Float(challenge.targetValue)) * 100))%")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "40C4FC"))
                }
            }
            
            // Progress in numbers and View button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "666666"))
                    
                    Text("\(currentProgress)/\(challenge.targetValue) \(challenge.field)s")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "333333"))
                }
                Spacer()
                
                // View button with more presence
                Button(action: {
                    showChallengeDetailsCover = true
                }) {
                    Text("View")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "40C4FC"))
                        .cornerRadius(8) // No rounded corners requested, but gives a cleaner button
                }
            }
        }
        .padding(16)
        .background(Color(hex: "F9F9F9"))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 0)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .fullScreenCover(isPresented: $showChallengeDetailsCover, content: {
            ChallengeDetailsView(challenge: challenge, currentProgress: currentProgress)
        })
    }
    
    func formattedChallengeName(_ name: String) -> String {
        return name
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = dateFormatter.date(from: dateString) else {
            return "Invalid Date"
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd"
        
        return outputFormatter.string(from: date)
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
