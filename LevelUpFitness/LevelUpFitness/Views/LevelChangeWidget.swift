//
//  LevelChangeWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/11/24.
//

import SwiftUI

struct LevelChangeWidget: View {
    var levelChangeInfo: LevelChangeInfo
    
    private var circleColor: Color {
        if levelChangeInfo.change > 0 {
            return .green
        } else if levelChangeInfo.change < 0 {
            return .red
        } else {
            return .gray
        }
    }
    
    private var arrowImage: String {
        if levelChangeInfo.change > 0 {
            return "arrow.up"
        } else if levelChangeInfo.change < 0 {
            return "arrow.down"
        } else {
            return "arrow.right"
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(circleColor)
                    .overlay(
                        Image(systemName: arrowImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .padding(17)
                    )
                
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.black)
                    .rotationEffect(Angle(degrees: 270.0))
            }
            
            Text(levelChangeInfo.keyword)
                .font(.headline)
            
//            Text("\(abs(levelChangeInfo.change))")
//                .font(.headline)
//                .bold()
        }
    }
}

#Preview {
    LevelChangeWidget(levelChangeInfo: LevelChangeInfo(keyword: "Weight", description: "Weight trend", change: -5, timestamp: ""))
        .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
}
