//
//  SubLevelCircularWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/6/24.
//

import SwiftUI
import UIKit

struct SubLevelCircularWidget: View {
    var level: Int
    var image: String
    var name: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "E8F3FF"), Color(hex: "F8FAFF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Group {
                    if UIImage(named: image) != nil {
                        Image(image)
                            .resizable()
                            .scaledToFit()
                            .padding(10)
                    } else {
                        Image(systemName: "bolt.heart.fill")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(hex: "0B5ED7"))
                    }
                }
            }
            .frame(width: 88, height: 88)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )

            Text(name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
                .lineLimit(1)

            Text("Level \(level)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(hex: "0B5ED7"))
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SubLevelCircularWidget(level: 5, image: "Dumbbell", name: "Strength")
}
