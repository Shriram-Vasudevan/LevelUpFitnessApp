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
    
    @State private var width: CGFloat = 50
    
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
                    
                    Text(badge.badgeDescription)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            
            GeometryReader { geometry in
                HStack (spacing: 10) {
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: geometry.size.width * 0.7, height: 20)
                        
                        if userBadgeInfo.weeks <= badge.badgeCriteria.threshold {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: CGFloat(userBadgeInfo.weeks) / CGFloat(badge.badgeCriteria.threshold) * geometry.size.width * 0.7, height: 20)
                        } else {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: geometry.size.width * 0.7, height: 20)
                        }
                    }
                        
                    Spacer()
                    
                    Text(userBadgeInfo.weeks > badge.badgeCriteria.threshold ? "100%" : "\(Int(CGFloat(userBadgeInfo.weeks) / CGFloat(badge.badgeCriteria.threshold) * 100))%")
                        .bold()
                }
            }
            .padding(.bottom, 10)
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
    AchievementWidget(userBadgeInfo: UserBadgeInfo(userId: "Test", weeks: 3, badgesEarned: [""]), badge: Badge(id: "Test", badgeName: "Memory Master", badgeDescription: "Completed your first week of workouts! You're off to a strong start!", badgeIconS3URL: "Test", badgeCriteria: BadgeCriteria(field: "weeks", threshold: 5)))
}



