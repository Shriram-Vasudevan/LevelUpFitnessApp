//
//  ProgramStatsButtonWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/2/24.
//

import SwiftUI

struct ProgramStatsButton: View {
    @Binding var navigateToMetricsView: Bool
    
    var body: some View {
        Button(action: {
            navigateToMetricsView = true
        }) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Program Stats")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(.primary)
                        Text("Metrics")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chart.pie.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.blue.opacity(0.5), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

#Preview {
    ProgramStatsButton(navigateToMetricsView: .constant(false))
}
