//
//  SubLevelCircularWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import SwiftUI

struct SubLevelCircularWidget: View {
    var level: Int
    var image: String
    var name: String
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(Color(red: 24 / 255.0, green: 44 / 255.0, blue: 67 / 255.0))
                    .overlay (
                        Image(image)
                            .resizable()
//                            .rotationEffect(.degrees(45))
                            .clipped()
                            .padding(5)
                    )
                
                
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.black)
                    .rotationEffect(Angle(degrees: 270.0))
            }
            
            Text(name)
                .font(.headline)
            
            Text("Level \(level)")
                .font(.headline)
                .bold()
        }
    }
}

#Preview {
    SubLevelCircularWidget(level: 5, image: "Dumbell", name: "Strength")
        .frame(width: UIScreen.main.bounds.width / 4.5, height: UIScreen.main.bounds.width / 4.5)
}
