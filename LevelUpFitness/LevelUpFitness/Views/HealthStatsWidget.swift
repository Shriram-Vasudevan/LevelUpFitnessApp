//
//  HealthStatsWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/6/24.
//

import SwiftUI

struct HealthStatsWidget: View {
    var stat: (count: Int, comparison: HealthComparison)
    var text: String
    var imageName: String
    
    var healthStatWidgetPressed: (String) -> Void
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Image(systemName: imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(.black)
                    Text(text)
                        .font(.title)
                        .foregroundColor(.black)
                        .bold()
                }
                
                HStack {
                    Text("\(stat.count)")
                        .font(.system(size: 35, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                    
                    switch stat.comparison {
                        case .equal:
                            Image(systemName: "arrow.right.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    case .greater:
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.green)
                    case .less:
                        Image(systemName: "arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.red)
                    }
                    
                    
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(radius: 5)
        )
        .padding()
        .onTapGesture {
            healthStatWidgetPressed(text)
        }
    }
}


#Preview {
    HealthStatsWidget(stat: (count: 100, comparison: .greater), text: "Steps", imageName: "figure.walk", healthStatWidgetPressed: {_ in })
}

