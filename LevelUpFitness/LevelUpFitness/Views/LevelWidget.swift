//
//  LevelWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import SwiftUI

struct LevelWidget: View {
    @State var userXPData: XPData
    
    var body: some View {
        VStack {
            HStack {
                LevelCircularProgressBar(progress: Double(userXPData.xp) / Double(userXPData.xpNeeded), level: userXPData.level)
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 5)
                    .padding(.leading)
                
                VStack(alignment: .leading) {
                    Text("Let's get that Level Up!")
                        .font(.headline)
                        .bold()
                    Text("Here's a Full Breakdown")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.bottom)
            
            HStack {
                SubLevelCircularWidget(level: userXPData.subLevels.strength.level, image: "Dumbell", name: "Strength")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
                
                Spacer()
                
                SubLevelCircularWidget(level: userXPData.subLevels.endurance.level, image: "Running", name: "Endurance")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
                
                Spacer()
                
                SubLevelCircularWidget(level: userXPData.subLevels.power.level, image: "Power", name: "Power")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
                
                Spacer()
                
                SubLevelCircularWidget(level: userXPData.subLevels.mobility.level, image: "360", name: "Mobility")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
    
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.white)
                .shadow(radius: 3)
        )
//        .padding()
       
    }
}

#Preview {
    LevelWidget(userXPData: XPData(userID: "", xp: 102, level: 2, xpNeeded: 150, subLevels: Sublevels(strength: Sublevel(level: 0, xp: 0, xpNeeded: 0), power: Sublevel(level: 0, xp: 0, xpNeeded: 0), endurance: Sublevel(level: 0, xp: 0, xpNeeded: 0), mobility: Sublevel(level: 0, xp: 0, xpNeeded: 0))))
}
