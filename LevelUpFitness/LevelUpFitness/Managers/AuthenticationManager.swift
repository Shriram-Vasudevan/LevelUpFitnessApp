//
//  AuthenticationManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/20/24.
//

import Amplify
import AWSCognitoAuthPlugin
import AWSAPIPlugin
import AWSS3StoragePlugin
import AWSPinpoint
import SwiftUI

//Handles Sign In + Login Stuff
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var username: String?
    @Published var name: String?
//    static var pfp: Data?
    
    
    func login(username: String, password: String, completion: @escaping (Bool, String?, Error?) async -> Void) async {
        do {
            let signInResult = try await Amplify.Auth.signIn(
                username: username, //can be a username or email
                password: password
                )
            if signInResult.isSignedIn {
                print("Sign in succeeded")
                if let userID = try? await Amplify.Auth.getCurrentUser().userId {
                    await getUsername()
                    await completion(true, userID, nil)
                } else {
                    await completion(true, nil, nil)
                }
            }
        } catch let error as AuthError {
            print("Sign in failed \(error)")
            await completion(false, nil, error)
        } catch {
            print("Unexpected error: \(error)")
            await completion(false, nil, error)
        }
    }
    
    func register(email: String, name: String, username: String, password: String, completion: @escaping (Bool, String?, Error?) async -> Void) async {
        let userAttributes = [
            AuthUserAttribute(.custom("username"), value: username),
            AuthUserAttribute(.name, value: name)
        ]
        
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        
        do {
            let signUpResult = try await Amplify.Auth.signUp(username: email, password: password, options: options)
            
            if case let .confirmUser(deliveryDetails, _, userID) = signUpResult.nextStep {
                print("Delivery details \(String(describing: deliveryDetails)) for userID: \(String(describing: userID))")
                await completion(true, userID, nil)
            } else {
                print("SignUp Complete")
                //completion(true, userId, nil)
            }
        } catch let error as AuthError {
            print("An error occurred while registering a user \(error)")
            await completion(false, nil, error)
        } catch {
            print("Unexpected error: \(error)")
            await completion(false, nil, error)
        }
    }
    
    func confirm(email: String, code: String, completion: @escaping (Bool, Error?) -> Void) async {
        do {
            let confirmSignUpResult = try await Amplify.Auth.confirmSignUp(
                for: email,
                confirmationCode: code
            )
            print("Confirm sign up result completed: \(confirmSignUpResult.isSignUpComplete)")
            completion(true, nil)
        } catch let error as AuthError {
            print("An error occurred while confirming sign up \(error)")
            completion(false, error)
        } catch {
            print("Unexpected error: \(error)")
            completion(false, error)
        }
    }
    

    func signOut() async {
        let result = await Amplify.Auth.signOut()
        guard let signOutResult = result as? AWSCognitoSignOutResult
        else {
            print("Signout failed")
            return
        }

        print("Local signout successful: \(signOutResult.signedOutLocally)")
        switch signOutResult {
        case .complete:
            print("Signed out successfully")

        case let .partial(revokeTokenError, globalSignOutError, hostedUIError):
            
            if let hostedUIError = hostedUIError {
                print("HostedUI error  \(String(describing: hostedUIError))")
            }

            if let globalSignOutError = globalSignOutError {
                print("GlobalSignOut error  \(String(describing: globalSignOutError))")
            }

            if let revokeTokenError = revokeTokenError {
                print("Revoke token error  \(String(describing: revokeTokenError))")
            }

        case .failed(let error):
            print("SignOut failed with \(error)")
        }
    }
    
    func deleteUser() async {
        do {
            try await Amplify.Auth.deleteUser()
            print("Successfully deleted user")
        } catch let error as AuthError {
            print("Delete user failed with error \(error)")
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func forgotPassword(username: String) async {
        
    }
    
    func getProfilePicture() async -> Data? {
        do {
            let userID = try await Amplify.Auth.getCurrentUser().userId
            
            let downloadTask = Amplify.Storage.downloadData(key: "pfp-media/\(userID).png")
            
            let data = try await downloadTask.value
            
            return data
        } catch {
            print(error)
            return nil
        }
    }
    
    func uploadProfilePicture(userID: String) async {
        print(userID)
        
        if await pfpUploaded(userID: userID) {
            return
        }
        else {
            guard let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            let pfpUrl = directoryUrl.appendingPathComponent("pfp-\(userID).png", isDirectory: false)
            if FileManager.default.fileExists(atPath: pfpUrl.path) {
                guard let pfpData = FileManager.default.contents(atPath: pfpUrl.path) else { return
                }
                
                let uploadTask = Amplify.Storage.uploadData(key: "pfp-media/\(userID).png", data: pfpData)
        
                for await progress in await uploadTask.progress {
                    print("Progress: \(progress)")
                }
        
                do {
                    let value = try await uploadTask.value
                    print("Completed: \(value)")
                } catch {
                    if let storageError = error as? StorageError {
                        print(storageError.errorDescription)
                    }
                    else {
                        print(error.localizedDescription)
                    }
                }
                
            }
            else {
                return
            }
        }

    }
    
    func pfpUploaded(userID: String) async -> Bool {
        do {
            let options = StorageListRequest.Options(path: "pfp-media/\(userID).png", pageSize: 1)
            let listResult = try await Amplify.Storage.list(options: options)
            return listResult.items.count > 0
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getUsername() async {
        do {
            let userAttributes = try await Amplify.Auth.fetchUserAttributes()
            print("User attributes - \(userAttributes)")
            
            let usernameAttribute = userAttributes.first(where: { $0.key == .custom("username") })
            
            self.username = usernameAttribute?.value ?? ""
            print("the username: " + (self.username ?? "not existent"))
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func getName() async {
        do {
            let userAttributes = try await Amplify.Auth.fetchUserAttributes()
            
            let nameAttribute = userAttributes.first(where: { $0.key == .name })
            
            self.name = nameAttribute?.value ?? ""
            print("the username: " + (self.name ?? ""))
        } catch {
            print("Unexpected error: \(error)")
        }
    }

}
