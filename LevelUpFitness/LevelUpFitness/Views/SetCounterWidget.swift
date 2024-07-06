//
//  SetCounterWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import SwiftUI

struct SetCounterWidget: View {
    var colorA: Color
    var colorB: Color
    
    @State var stat: String
    var text: String
    
    var width: CGFloat
    
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
                        .clipped()
                        
                        VStack {
                            Spacer()
                            
                            Text(stat)
                                .font(.custom("EtruscoNowCondensed Bold", size: 30))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                
                            

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
    SetCounterWidget(colorA: .blue, colorB: .cyan, stat: "1", text: "of 5", width: UIScreen.main.bounds.width / 6)
}
