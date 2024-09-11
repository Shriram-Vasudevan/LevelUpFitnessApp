//
//  ProfileView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/6/24.
//

import SwiftUI
import PhotosUI
import Amplify

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showDeleteConfirmation = false
    @State private var showProfilePictureOptions = false
    @State private var selectedProfilePicture: PhotosPickerItem?
    @State private var pfpData: Data?
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    settingsSection
                    accountActions
                }
                .padding()
            }
        }
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "40C4FC"))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.custom("Sailec Bold", size: 20))
                    .foregroundColor(.black)
            }
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await AuthenticationManager.shared.deleteUser()
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .sheet(isPresented: $showProfilePictureOptions) {
            profilePictureOptionsSheet
        }
        .onChange(of: selectedProfilePicture) { _ in
            Task {
                if let data = try? await selectedProfilePicture?.loadTransferable(type: Data.self) {
                    pfpData = data
                    if let userID = try? await Amplify.Auth.getCurrentUser().userId {
                        saveProfilePictureLocally(pfpData: data, userID: userID)
                        await AuthenticationManager.shared.uploadProfilePicture(userID: userID)
                    }
                }
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            Button(action: { showProfilePictureOptions = true }) {
                if let pfpData = authManager.pfp, let uiImage = UIImage(data: pfpData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "40C4FC"), lineWidth: 3))
                } else {
                    Image("NoProfile")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "40C4FC"), lineWidth: 3))
                }
            }
            
            VStack(spacing: 4) {
                Text(authManager.username ?? "Checking")
                    .font(.system(size: 22, weight: .bold))
                Text(authManager.name ?? "Checking")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "666666"))
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(20)
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "333333"))
                .padding(.leading, 8)
            
            ForEach(SettingsOption.allCases, id: \.self) { option in
                Button(action: { }) {
                    HStack {
                        Image(systemName: option.iconName)
                            .foregroundColor(Color(hex: "40C4FC"))
                            .frame(width: 30)
                        
                        Text(option.title)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(hex: "CCCCCC"))
                    }
                }
                .foregroundColor(Color(hex: "333333"))
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private var accountActions: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task {
                    await AuthenticationManager.shared.signOut()
                }
            }) {
                Text("Sign Out")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(15)
            }
            
            Button(action: {
                showDeleteConfirmation = true
            }) {
                Text("Delete Account")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.red)
            }
        }
        .padding(.top, 16)
    }
    
    private var profilePictureOptionsSheet: some View {
        VStack(spacing: 20) {
            PhotosPicker(selection: $selectedProfilePicture, matching: .images, photoLibrary: .shared()) {
                Text("Change Profile Picture")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: "40C4FC"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC").opacity(0.1))
                    .cornerRadius(10)
            }
            
            Button(action: {
                Task {
                    await AuthenticationManager.shared.removeProfilePicture()
                    showProfilePictureOptions = false
                }
            }) {
                Text("Remove Profile Picture")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
            }
        }
        .padding(24)
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(20)
        .presentationDetents([.height(200)])
    }
    
    func saveProfilePictureLocally(pfpData: Data, userID: String) {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let pfpURL = documentsDirectory.appendingPathComponent("pfp-\(userID).png", isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: pfpURL.path) {
            do {
                try pfpData.write(to: pfpURL)
            } catch {
                print(error.localizedDescription)
            }
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
