//
//  AuthCheckView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct AuthCheckView: View {
    @ObservedObject var authObserver = AuthStateObserver.shared
    
    var body: some View {
        VStack {
            if authObserver.isSignedIn {
                PagesHolderView(pageType: .home)
                    .preferredColorScheme(.light)
            } else if !authObserver.hasFinishedChecking {
                SplashScreenView()
                    .preferredColorScheme(.light)
            } else {
                LoginView()
                    .preferredColorScheme(.light)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: authObserver.hasFinishedChecking)
        .onAppear {
            authObserver.checkAuthState()
        }
    }
}

#Preview {
    AuthCheckView()
}
