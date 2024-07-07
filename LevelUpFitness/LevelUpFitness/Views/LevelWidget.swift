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
                    .padding(.leading, 5)
                
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
                SubLevelCircularWidget(level: 2, image: "Dumbell", name: "Strength")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
                
                Spacer()
                
                SubLevelCircularWidget(level: 1, image: "Running", name: "Endurance")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
                
                Spacer()
                
                SubLevelCircularWidget(level: 3, image: "Power", name: "Power")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
                
                Spacer()
                
                SubLevelCircularWidget(level: 1, image: "360", name: "Mobility")
                    .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
    
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.white)
                .shadow(radius: 3)
        )
        .padding()
       
    }
}

#Preview {
    LevelWidget(userXPData: XPData(userID: "", xp: 102, level: 2, xpNeeded: 150))
}
