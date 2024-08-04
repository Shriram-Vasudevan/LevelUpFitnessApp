//
//  FullLevelBreakdownView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/4/24.
//

import SwiftUI

struct FullLevelBreakdownView: View {
    @State var userXPData: XPData
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack {
                    ZStack {
                        HStack {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(.black)
                            }

                            
                            Spacer()
                        }
                        
                        Text("Full Breakdown")
                            .bold()
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Level \(userXPData.level)")
                            .font(.custom("EtruscoNowCondensed Bold", size: 70))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))
                    )
                    .padding()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    FullLevelBreakdownView(userXPData: XPData(userID: "", level: 2, subLevels: Sublevels(mobility: XPAttribute(xp: 0, level: 0, xpNeeded: 0), endurance: XPAttribute(xp: 0, level: 0, xpNeeded: 0), strength: XPAttribute(xp: 0, level: 0, xpNeeded: 0), bodyAreas: BodyAreas(back: XPAttribute(xp: 0, level: 0, xpNeeded: 0), legs: XPAttribute(xp: 0, level: 0, xpNeeded: 0), chest: XPAttribute(xp: 0, level: 0, xpNeeded: 0), shoulders: XPAttribute(xp: 0, level: 0, xpNeeded: 0), core: XPAttribute(xp: 0, level: 0, xpNeeded: 0)))))
}
