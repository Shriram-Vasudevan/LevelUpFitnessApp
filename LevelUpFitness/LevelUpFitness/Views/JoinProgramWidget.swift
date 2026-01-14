//
//  JoinProgramWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/2/24.
//

import SwiftUI

struct JoinProgramWidget: View {
    var standardProgramDBRepresentation: StandardProgramDBRepresentation
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(standardProgramDBRepresentation.name)
                    .font(.system(size: 22, weight: .bold, design: .default))
                    .foregroundColor(.black)

                Spacer()

                if standardProgramDBRepresentation.isPremium {
                    Text(storeKitManager.effectiveIsPremiumUnlocked ? "Premium" : "Unlock")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "40C4FC"))
                        .clipShape(Capsule())
                }
            }

            HStack {
                programInfoItem(title: "Environment:", value: standardProgramDBRepresentation.environment)
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(Color(hex: "40C4FC"))
                    .font(.system(size: 24))
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(8)
    }
    
    private func programInfoItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .ultraLight, design: .default))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 16, weight: .light, design: .default))
                .foregroundColor(.black)
        }
    }
}

#Preview {
    JoinProgramWidget(
        standardProgramDBRepresentation: StandardProgramDBRepresentation(
            id: "vwerfwefegrw",
            name: "Muscle Maximization Program",
            environment: "Gym",
            image: "",
            description: "A high-intensity split to ramp up strength",
            isPremium: true
        )
    )
    .environmentObject(StoreKitManager.shared)
}
