//
//  GymSessionsInfoView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 10/1/24.
//

import SwiftUI

struct GymSessionsInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    GymSessionsInfoView()
}
