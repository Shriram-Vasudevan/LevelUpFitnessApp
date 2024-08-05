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
    
    let sublevelKeys = [
        Sublevels.CodingKeys.strength.rawValue,
        Sublevels.CodingKeys.endurance.rawValue,
        Sublevels.CodingKeys.mobility.rawValue
    ]
    
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
                    
                    HStack {
                        Text("Core Sublevels")
                            .font(.custom("Sailec Medium", size: 30))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                    
                    ForEach(sublevelKeys, id: \.self) { key in
                        if let attribute = userXPData.subLevels.attribute(for: key) {
                            HStack {
                                Text(key.capitalizingFirstLetter())
                                    .bold()
                                    .font(.system(size: 20))
                                
                                Spacer()
                                
                                Text("\(attribute.xp) / \(attribute.xpNeeded)")
                                    .foregroundColor(.gray)
                            }
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: .infinity, height: 30)
                                
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.green)
                                    .frame(width: CGFloat(attribute.xp) / CGFloat(attribute.xpNeeded) * .infinity, height: 30)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    FullLevelBreakdownView(userXPData: XPData(userID: "", level: 2, subLevels: Sublevels(mobility: XPAttribute(xp: 0, level: 0, xpNeeded: 0), endurance: XPAttribute(xp: 0, level: 0, xpNeeded: 0), strength: XPAttribute(xp: 0, level: 0, xpNeeded: 0), bodyAreas: BodyAreas(back: XPAttribute(xp: 0, level: 0, xpNeeded: 0), legs: XPAttribute(xp: 0, level: 0, xpNeeded: 0), chest: XPAttribute(xp: 0, level: 0, xpNeeded: 0), shoulders: XPAttribute(xp: 0, level: 0, xpNeeded: 0), core: XPAttribute(xp: 0, level: 0, xpNeeded: 0)))))
}
