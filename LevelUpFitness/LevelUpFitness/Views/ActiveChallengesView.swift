//
//  ActiveChallengesView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/21/24.
//

import SwiftUI

struct ActiveChallengesView: View {
    @ObservedObject var challengeManager = ChallengeManager.shared
    @ObservedObject var xpManager = XPManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "F3F5F8").ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(spacing: 14) {
                    header

                    if availableTemplates.isEmpty {
                        fallbackState
                    } else {
                        ForEach(availableTemplates, id: \.id) { template in
                            ChallengeTemplateWidget(challenge: template) {
                                Task {
                                    if let userXPData = xpManager.userXPData {
                                        let success = await challengeManager.createChallenge(
                                            challengeName: template.name,
                                            challengeTemplateID: template.id,
                                            userXPData: userXPData
                                        )
                                        if success {
                                            dismiss()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Available Challenges")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var fallbackState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No new challenges available right now.")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            Text("Check back later for new challenge drops and seasonal events.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var availableTemplates: [ChallengeTemplate] {
        challengeManager.challengeTemplates.filter { challengeTemplate in
            !challengeManager.userChallenges.contains { userChallenge in
                userChallenge.challengeTemplateID == challengeTemplate.id
            }
        }
    }
}

#Preview {
    ActiveChallengesView()
}
