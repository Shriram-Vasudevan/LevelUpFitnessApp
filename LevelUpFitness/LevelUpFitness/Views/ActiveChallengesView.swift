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
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            VStack (spacing: 12) {
                HStack {
                    Text("Available Challeges")
                        .font(.system(size: 22, weight: .bold, design: .default))
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
                .padding(.top)
                .padding(.bottom, 12)
                
                ScrollView(.vertical) {
                    ForEach(challengeManager.challengeTemplates.filter { challengeTemplate in
                        !challengeManager.userChallenges.contains { userChallenge in
                            userChallenge.challengeTemplateID == challengeTemplate.id
                        }
                    }, id: \.id) { challengeTemplate in
                        ChallengeTemplateWidget(challenge: challengeTemplate) {
                            Task {
                                if let userXPData = xpManager.userXPData {
                                    let success = await challengeManager.createChallenge(challengeName: challengeTemplate.name, challengeTemplateID: challengeTemplate.id, userXPData: userXPData)
                                    
                                    if success {
                                        dismiss()
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    ActiveChallengesView()
}
