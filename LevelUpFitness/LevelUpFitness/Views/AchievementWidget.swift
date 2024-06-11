//
//  AchievementWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/3/24.
//

import SwiftUI

struct AchievementWidget: View {
    var userBadgeInfo: UserBadgeInfo
    var badge: Badge
    
    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            HStack {
                Image("AchievementBadge")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                
                VStack (alignment: .leading, spacing: 5) {
                    Text(badge.badgeName)
                        .bold()
                    
                    Text("Completed 5 workout sessions! Your dedication is inspiring!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            HStack (spacing: 10) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: UIScreen.main.bounds.width * 0.6, height: 20)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: CGFloat(userBadgeInfo.weeks) / CGFloat(badge.badgeCriteria.threshold) * UIScreen.main.bounds.width * 0.6, height: 20)
                }
                
                Spacer()
                
                Text("\(Int(CGFloat(userBadgeInfo.weeks) / CGFloat(badge.badgeCriteria.threshold) * 100))%")
                    .bold()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}

#Preview {
    AchievementWidget(userBadgeInfo: UserBadgeInfo(userId: "Test", weeks: 3, badgesEarned: [""]), badge: Badge(id: "Test", badgeName: "Memory Master", badgeIconS3URL: "Test", badgeCriteria: BadgeCriteria(field: "weeks", threshold: 5)))
}

