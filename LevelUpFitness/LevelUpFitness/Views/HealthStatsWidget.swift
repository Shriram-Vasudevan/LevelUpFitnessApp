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
    
    var color: Color
    
    var healthStatWidgetPressed: (String) -> Void
    var body: some View {
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .foregroundColor(.black)
                        
                        Text(text)
                            .font(.title3)
                            .foregroundColor(.black)
                            .bold()
                    }
                    HStack {
                        switch stat.comparison {
                            case .equal:
                                Image(systemName: "arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                                Text("- Constant")
                        case .greater:
                            Image(systemName: "arrow.up.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.green)
                            Text("- Increasing")
                        case .less:
                            Image(systemName: "arrow.down.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.red)
                            Text("- Decreasing")
                        }
                        
                    }
                    
                    HStack {
                        Spacer()
                        
                        Text("\(stat.count)")
                            .font(.custom("YanoneKaffeesatz-Bold", size: 45))
                            .foregroundColor(.black)
                            .padding(.top, 5)
                        
                        
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
//                .shadow(radius: 5)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        )
        .padding(.vertical)
        .onTapGesture {
            healthStatWidgetPressed(text)
        }
    }
}


#Preview {
    HealthStatsWidget(stat: (count: 100, comparison: .greater), text: "Steps", imageName: "figure.walk", color: .red, healthStatWidgetPressed: {_ in })
}

