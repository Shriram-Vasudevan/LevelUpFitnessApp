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
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedChallengeName(challenge.name))
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "333333"))
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                    
                    Text("\(formatDate(challenge.startDate)) - \(formatDate(challenge.endDate))")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(Color(hex: "666666"))
                }
                
                Spacer()
                
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
                        .font(.custom("Poppins-SemiBold", size: 12))
                        .foregroundColor(Color(hex: "40C4FC"))
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Progress")
                        .font(.custom("Poppins-Medium", size: 14))
                        .foregroundColor(Color(hex: "666666"))
                    
                    Text("\(currentProgress)/\(challenge.targetValue) \(challenge.field)s")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "333333"))
                }
                
                Spacer()
                
                Button(action: {
                    showChallengeDetailsCover = true
                }) {
                    Text("View")
                        .font(.custom("Poppins-Medium", size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "40C4FC"))
                        .cornerRadius(20)
                }
            }
        }
        .padding(20)
        .background(Color(hex: "F5F5F5"))
        .overlay(
            Rectangle()
                .fill(Color(hex: "40C4FC"))
                .frame(width: 4)
                .padding(.vertical, 20),
            alignment: .leading
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

struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "E0E0E0"))
                    .frame(height: 4)
                
                RoundedRectangle(cornerRadius: 2)
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
