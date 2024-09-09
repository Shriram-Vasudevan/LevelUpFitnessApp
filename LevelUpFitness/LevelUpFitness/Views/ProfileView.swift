//
//  ProfileView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/6/24.
//

import SwiftUI

struct ProfileView: View {
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Profile")
                    .font(.custom("Sailec Bold", size: 20))
                    .foregroundColor(.black)
                    .padding(.bottom, 50)
                
                
                VStack(spacing: 16) {
                    Image("ProfilePicture")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "40C4FC"), lineWidth: 2))
                    
                    VStack(spacing: 4) {
                        Text("JohnDoe123")
                            .font(.system(size: 22, weight: .bold, design: .default))
                        Text("John Doe")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Settings")
                        .font(.system(size: 20, weight: .medium, design: .default))
                    
                    ForEach(SettingsOption.allCases, id: \.self) { option in
                        Button(action: {
                            
                        }) {
                            HStack {
                                Image(systemName: option.iconName)
                                    .foregroundColor(Color(hex: "40C4FC"))
                                    .frame(width: 30)
                                
                                Text(option.title)
                                    .font(.system(size: 16, weight: .regular, design: .default))
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .foregroundColor(.black)
                    }
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        Task {
                            await AuthStateObserver.shared.signOut()
                        }
                    }) {
                        Text("Sign Out")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "40C4FC"))
                    }
                    
                    Button(action: {
                        showDeleteConfirmation = true
                    }) {
                        Text("Delete Account")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .foregroundColor(.red)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .navigationBarBackButtonHidden()
    }
    
    func buttonAction(settingsOption: String) {
        switch settingsOption {
            
            default:
                break
        }
    }

}

enum SettingsOption: CaseIterable {
    case personalInfo
    case notifications
    case privacy
    case dataUsage
    case help
    
    var title: String {
        switch self {
        case .personalInfo: return "Personal Information"
        case .notifications: return "Notifications"
        case .privacy: return "Privacy"
        case .dataUsage: return "Data Usage"
        case .help: return "Help & Support"
        }
    }
    
    var iconName: String {
        switch self {
        case .personalInfo: return "person.fill"
        case .notifications: return "bell.fill"
        case .privacy: return "lock.fill"
        case .dataUsage: return "chart.bar.fill"
        case .help: return "questionmark.circle.fill"
        }
    }
}

#Preview {
    ProfileView()
}
