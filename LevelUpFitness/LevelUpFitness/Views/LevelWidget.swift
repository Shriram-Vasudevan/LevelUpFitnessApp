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
        VStack {
            HStack {
                Spacer()
                
                Button {
                    openLevelUpInfoView()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.black)
                }
                

            }
            .padding(.horizontal)
            .padding(.bottom, -15)
            HStack {
                LevelCircularProgressBar(progress: 1.0, level: userXPData.level)
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 5)
                    .padding(.leading)
                
                VStack(alignment: .leading) {
                    Text("Let's get that Level Up!")
                        .font(.headline)
                        .bold()
                        .foregroundColor(.black)
                    
                    Text("Here's a quick breakdown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
            }
            .padding(.bottom)
            
            if levelChanges.count > 0 {
                HStack {
                    ForEach(levelChanges, id: \.id) { levelChange in
                        LevelChangeWidget(levelChangeInfo: levelChange)
                            .frame(width: UIScreen.main.bounds.width / 5, height: UIScreen.main.bounds.width / 5)
                    }
                }
            } else {
                HStack {
                    Text("No Recent Changes to Show!")
                }
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
//                .fill(LinearGradient(colors: [Color(red: 67 / 255.0, green: 24 / 255.0, blue: 44 / 255.0), Color(red: 44 / 255.0, green: 67 / 255.0, blue: 24 / 255.0)], startPoint: .top, endPoint: .bottom))
        
        )
//        .padding()
       
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
