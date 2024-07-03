//
//  AuthStateObserver.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import Foundation
import Combine
import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin

class AuthStateObserver: ObservableObject {
    @Published var isSignedIn = false
    @Published var hasFinishedChecking = false
    
    func checkAuthState() {
        Task {
            do {
               // await Amplify.Auth.signOut()
                let authResult = try await Amplify.Auth.fetchAuthSession()
                DispatchQueue.main.sync {
                    self.isSignedIn = authResult.isSignedIn
                    self.hasFinishedChecking = true
                    
                    if self.isSignedIn {
                        Task {
                            print("signed in")
                            await AuthenticationManager.getUsername()
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("not signed in")
                    self.isSignedIn = false
                    self.hasFinishedChecking = true
                }
            }
        }
    }
}
