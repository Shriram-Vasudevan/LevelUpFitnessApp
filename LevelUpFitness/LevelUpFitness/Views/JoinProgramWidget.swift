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
        HStack(spacing: 12) {
            ProgramPreviewImage(reference: standardProgramDBRepresentation.image)
                .frame(width: 82, height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(standardProgramDBRepresentation.environment)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Color(hex: "E8F3FF"))
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    if standardProgramDBRepresentation.requiresSubscription {
                        Text(storeKitManager.canAccessProgram(standardProgramDBRepresentation) ? "Premium" : "Subscription Required")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "A16207"))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color(hex: "FEF3C7"))
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }

                Text(standardProgramDBRepresentation.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))
                    .lineLimit(2)

                Text(standardProgramDBRepresentation.description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "6B7280"))
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "arrow.right.circle.fill")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(Color(hex: "0B5ED7"))
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
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
