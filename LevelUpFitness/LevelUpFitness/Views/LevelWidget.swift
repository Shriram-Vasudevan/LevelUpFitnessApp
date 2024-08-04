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
            
            HStack {
                SubLevelCircularWidget(level: userXPData.subLevels.strength.level, image: "Dumbell", name: "Strength")
                    .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
                
                Spacer()
                
                SubLevelCircularWidget(level: userXPData.subLevels.endurance.level, image: "Running", name: "Endurance")
                    .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
                
                Spacer()
                
                SubLevelCircularWidget(level: userXPData.subLevels.mobility.level, image: "360", name: "Mobility")
                    .frame(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
    
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .shadow(radius: 3)
        )
//        .padding()
       
    }
}

#Preview {
    LevelWidget(userXPData: XPData(userID: "", level: 2, subLevels: Sublevels(mobility: XPAttribute(xp: 0, level: 0, xpNeeded: 0), endurance: XPAttribute(xp: 0, level: 0, xpNeeded: 0), strength: XPAttribute(xp: 0, level: 0, xpNeeded: 0), bodyAreas: BodyAreas(back: XPAttribute(xp: 0, level: 0, xpNeeded: 0), legs: XPAttribute(xp: 0, level: 0, xpNeeded: 0), chest: XPAttribute(xp: 0, level: 0, xpNeeded: 0), shoulders: XPAttribute(xp: 0, level: 0, xpNeeded: 0), core: XPAttribute(xp: 0, level: 0, xpNeeded: 0)))))
}
