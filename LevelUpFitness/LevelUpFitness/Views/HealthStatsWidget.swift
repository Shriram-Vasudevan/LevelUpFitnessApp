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
        Button(action: {
            healthStatWidgetPressed(text)
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: imageName)
                        .foregroundColor(Color(hex: "40C4FC"))
                    Text(text)
                        .font(.system(size: 18, weight: .medium))
                }
                
                Text("\(stat.count)")
                    .font(.system(size: 32, weight: .bold))
                
                HStack {
                    comparisonIcon
                    comparisonText
                }
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(hex: "F5F5F5"))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var comparisonIcon: some View {
        Group {
            switch stat.comparison {
            case .equal:
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
            case .greater:
                Image(systemName: "arrow.up")
                    .foregroundColor(.green)
            case .less:
                Image(systemName: "arrow.down")
                    .foregroundColor(.red)
            }
        }
    }
    
    private var comparisonText: some View {
        Group {
            switch stat.comparison {
            case .equal:
                Text("Constant")
            case .greater:
                Text("Increasing")
            case .less:
                Text("Decreasing")
            }
        }
    }
}

#Preview {
    HealthStatsWidget(stat: (count: 100, comparison: .greater), text: "Steps", imageName: "figure.walk", healthStatWidgetPressed: {_ in })
}
