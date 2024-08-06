//
//  HealthStatsWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/6/24.
//

import SwiftUI

struct HealthStatsWidget: View {
    var stat1: (count: Int, comparison: HealthComparison)
    var text1: String
    var imageName1: String
    
    var stat2: (count: Int, comparison: HealthComparison)
    var text2: String
    var imageName2: String
    
    var stat3: (count: Int, comparison: HealthComparison)
    var text3: String
    var imageName3: String
    
    var body: some View {
        ZStack {
            
            HStack {
                HealthStatWidgetComponent(stat: stat1, text: text1, imageName: imageName1)
                
                Spacer()
                
                Divider()
                    .frame(height: 50)
                
                Spacer()
                
                HealthStatWidgetComponent(stat: stat2, text: text2, imageName: imageName2)
                
                Spacer()
                
                Divider()
                    .frame(height: 50)
                
                Spacer()
                
                HealthStatWidgetComponent(stat: stat3, text: text3, imageName: imageName3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
        )
        .padding()
    }
}

struct HealthStatWidgetComponent: View {
    var stat: (count: Int, comparison: HealthComparison)
    var text: String
    var imageName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: imageName)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 60, height: 60)
                    .foregroundColor(.black)
                Text(text)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            HStack {
                Text("\(stat.count)")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                switch stat.comparison {
                    case .equal:
                        Image(systemName: "arrow.right.circle.fill")
                        .resizable()
                        .frame(width: 2, height: 22)
                        .foregroundColor(.blue)
                case .greater:
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.green)
                case .less:
                    Image(systemName: "arrow.down.circle.fill")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.red)
                }
                
                
            }
        }
    }

}

#Preview {
    HealthStatsWidget(stat1: (count: 100, comparison: .greater), text1: "Steps", imageName1: "figure.walk", stat2: (count: 100, comparison: .greater), text2: "Steps", imageName2: "figure.walk", stat3: (count: 100, comparison: .greater), text3: "Steps", imageName3: "figure.walk")
}

