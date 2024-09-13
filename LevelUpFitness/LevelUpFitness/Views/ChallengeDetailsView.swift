//
//  ChallengeDetailsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/12/24.
//

import SwiftUI

struct ChallengeDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    var challenge: UserChallenge
    var currentProgress: Int
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView {
                VStack(spacing: 24) {
                    progressSection
                    infoSection
                    actionSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var header: some View {
        ZStack {
            Text(challenge.name)
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(.white)
            
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color(hex: "40C4FC"))
    }
    
    private var progressSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color(hex: "F5F5F5"), lineWidth: 10)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: CGFloat(currentProgress) / CGFloat(challenge.targetValue))
                    .stroke(Color(hex: "40C4FC"), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 8) {
                    Text("\(Int((Float(currentProgress) / Float(challenge.targetValue)) * 100))%")
                        .font(.custom("Poppins-Bold", size: 32))
                        .foregroundColor(Color(hex: "40C4FC"))
                    
                    Text("Completed")
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundColor(Color(hex: "666666"))
                }
            }
            
            Text("\(currentProgress)/\(challenge.targetValue) \(challenge.field)")
                .font(.custom("Poppins-SemiBold", size: 18))
                .foregroundColor(Color(hex: "333333"))
        }
    }
    
    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            InfoRow(title: "Start Date", value: formatDate(challenge.startDate))
            Divider().background(Color(hex: "F5F5F5"))
            InfoRow(title: "End Date", value: formatDate(challenge.endDate))
            Divider().background(Color(hex: "F5F5F5"))
            InfoRow(title: "Status", value: challenge.isActive ? "Active" : "Inactive")
            Divider().background(Color(hex: "F5F5F5"))
            InfoRow(title: "Progress", value: "\(currentProgress) out of \(challenge.targetValue)")
        }
        .background(Color(hex: "F5F5F5"))
    }
    
    private var actionSection: some View {
        VStack(spacing: 16) {
            if challenge.isActive {
                Button(action: {
                    // Action to quit challenge
                }) {
                    Text("Quit Challenge")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "FF3B30"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "F5F5F5"))
                }
            }
        }
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

struct InfoRow: View {
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("Poppins-Medium", size: 16))
                .foregroundColor(Color(hex: "666666"))
            Spacer()
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color(hex: "333333"))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ChallengeDetailsView(
        challenge: UserChallenge(
            userID: "user123",
            id: "challenge1",
            challengeTemplateID: "template1",
            name: "30-Day Fitness Challenge",
            startDate: "2024-08-01T00:00:00.000Z",
            endDate: "2024-08-30T23:59:59.999Z",
            startValue: 0,
            targetValue: 30,
            field: "days",
            isFailed: false,
            isActive: true
        ),
        currentProgress: 18
    )
}
