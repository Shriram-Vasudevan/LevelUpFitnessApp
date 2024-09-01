//
//  LevelWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import SwiftUI

struct LevelWidget: View {
    @State var userXPData: XPData
    var levelChanges: [LevelChangeInfo]
    var openLevelUpInfoView: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            LevelCircularProgressBar(progress: 1.0, level: userXPData.level)
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Level Up!")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Let's get to work.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.8))
            }
            
            Spacer()
            
            Button(action: openLevelUpInfoView) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 1.0, green: 0.42, blue: 0.42),
                    Color(red: 0.98, green: 0.65, blue: 0.36)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
    }
}

#Preview {
    LevelWidget(
        userXPData: XPData(
            userID: "",
            level: 2,
            xp: 0,
            xpNeeded: 50,
            subLevels: Sublevels(
                lowerBodyCompound: XPAttribute(xp: 0, level: 0, xpNeeded: 0),
                lowerBodyIsolation: XPAttribute(xp: 0, level: 0, xpNeeded: 0),
                upperBodyCompound: XPAttribute(xp: 0, level: 0, xpNeeded: 0),
                upperBodyIsolation: XPAttribute(xp: 0, level: 0, xpNeeded: 0)
            )
        ),
        levelChanges: [
            LevelChangeInfo(keyword: "Weight", description: "Weight trend", change: -5, timestamp: ""),
            LevelChangeInfo(keyword: "Weight", description: "Weight trend", change: 5, timestamp: ""),
            LevelChangeInfo(keyword: "Weight", description: "Weight trend", change: -1, timestamp: ""),
            LevelChangeInfo(keyword: "Weight", description: "Weight trend", change: 0, timestamp: "")
        ],
        openLevelUpInfoView: {}
    )
}
