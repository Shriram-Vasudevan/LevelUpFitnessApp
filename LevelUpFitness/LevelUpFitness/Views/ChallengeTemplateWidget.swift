//
//  ChallengeTemplateWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/13/24.
//

import SwiftUI

struct ChallengeTemplateWidget: View {
    var challenge: ChallengeTemplate
    var challengeSelected: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(challenge.name)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    
                    Text(challenge.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color(hex: "40C4FC"))
            }
            
            Button(action: challengeSelected) {
                Text("Start")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(hex: "40C4FC"))
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
}

#Preview {
    ChallengeTemplateWidget(challenge: ChallengeTemplate(id: "", name: "Sample Challenge", description: "This is a sample challenge description", duration: 5, targetField: ""), challengeSelected: {})
}
