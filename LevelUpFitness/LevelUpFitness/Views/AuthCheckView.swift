//
//  AuthCheckView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct AuthCheckView: View {
    @EnvironmentObject var authStateObserver: AuthStateObserver
    
    var body: some View {
        VStack {
            if authStateObserver.isSignedIn {
                PagesHolderView(pageType: .home)
                    .preferredColorScheme(.light)
            } else if !authStateObserver.hasFinishedChecking {
                SplashScreenView()
                    .preferredColorScheme(.light)
            } else {
                LoginView()
                    .preferredColorScheme(.light)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.5), value: authStateObserver.hasFinishedChecking)
        .onAppear {
            authStateObserver.checkAuthState()
        }
    }
}

#Preview {
    AuthCheckView()
}
