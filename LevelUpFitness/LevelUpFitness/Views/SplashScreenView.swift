//
//  SplashScreenView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Image("LevelUpFitnessLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
        }
    }
}

#Preview {
    SplashScreenView()
}
