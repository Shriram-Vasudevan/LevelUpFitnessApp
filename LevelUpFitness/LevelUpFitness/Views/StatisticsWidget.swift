//
//  StatisticsWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/4/24.
//

import SwiftUI

struct StatisticsWidget: View {
    var width: CGFloat
    
    var colorA: Color
    var colorB: Color
    
    var stat: Double
    var text: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            colorA,
                            colorB
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: width, height: width)
                .overlay (
                    ZStack {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addCurve(
                                to: CGPoint(x: width, y: 0),
                                control1: CGPoint(x: 37.5, y: 15),
                                control2: CGPoint(x: 112.5, y: -15)
                            )
                        }
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    colorB,
                                    colorA
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: width, height: 20)
                        .padding(.top)
                        
                        VStack {
                            Text(String(format: "%.1f", stat))
                                .font(.custom("EtruscoNowCondensed Bold", size: 45))
                                .foregroundColor(.white)
                            
                            Spacer()
                            

                            Text(text)
                                .foregroundColor(.white)
                        }

                    }
                    .padding(.bottom)
                )
        }
    }
}

#Preview {
    StatisticsWidget(width: 150, colorA: .blue, colorB: .cyan, stat: 650, text: "Steps Today")
}
