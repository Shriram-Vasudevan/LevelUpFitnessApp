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
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: "40C4FC"))
                    Spacer()
                    Text(text)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                
                Text("\(stat.count)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.vertical, 4)
                
                HStack(spacing: 4) {
                    comparisonIcon
                    comparisonText
                }
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color(hex: "F9F9F9"))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper to display comparison icons
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
    
    // Helper to display comparison text
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
