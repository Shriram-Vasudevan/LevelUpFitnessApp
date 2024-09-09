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
    static let shared = AuthStateObserver()
    
    @Published var isSignedIn = false
    @Published var hasFinishedChecking = false
    
    func checkAuthState() {
        Task {
            do {
                let authResult = try await Amplify.Auth.fetchAuthSession()
                DispatchQueue.main.async {
                    self.isSignedIn = authResult.isSignedIn
                    self.hasFinishedChecking = true
                    
                    if self.isSignedIn {
                        Task {
                            print("signed in")
                            await AuthenticationManager.shared.getUsername()
                            await AuthenticationManager.shared.getName()
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
    
    func signOut() async {
        await AuthenticationManager.shared.signOut()
        isSignedIn = false
    }
    
    func deleteAccount() async {
        await AuthenticationManager.shared.deleteUser()
        isSignedIn = false
    }
}
