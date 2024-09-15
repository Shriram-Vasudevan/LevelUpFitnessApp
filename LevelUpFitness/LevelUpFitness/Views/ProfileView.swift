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
            
            VStack(spacing: 0) {
                navigationBar
                
                ScrollView {
                    VStack(spacing: 16) {
                        profileHeader
                        settingsSection
                        accountActions
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task { await AuthenticationManager.shared.deleteUser() }
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

    private var navigationBar: some View {
        ZStack {
            Text("Profile")
                .font(.system(size: 18, weight: .semibold))
            
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "40C4FC"))
                }
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Button(action: { showProfilePictureOptions = true }) {
                if let pfpData = authManager.pfp, let uiImage = UIImage(data: pfpData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                } else {
                    Image("NoProfile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authManager.name ?? "Checking")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                Text(authManager.username ?? "Checking")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: { }) {
                Text("Edit")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "40C4FC"))
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }
    
    private var settingsSection: some View {
        VStack(spacing: 1) {
            ForEach(SettingsOption.allCases, id: \.self) { option in
                Button(action: { }) {
                    HStack {
                        Image(systemName: option.iconName)
                            .foregroundColor(Color(hex: "40C4FC"))
                            .frame(width: 30)
                        Text(option.title)
                            .font(.system(size: 16, weight: .regular))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(Color.white)
                }
                .foregroundColor(.black)
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
    
    private var accountActions: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task { await AuthenticationManager.shared.signOut() }
            }) {
                Text("Sign Out")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
            }
            
            Button(action: { showDeleteConfirmation = true }) {
                Text("Delete Account")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var profilePictureOptionsSheet: some View {
        VStack(spacing: 0) {
            Text("Profile Picture Options")
                .font(.system(size: 20, weight: .medium))
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hex: "F5F5F5"))
            
            Divider()
            
            VStack(spacing: 1) {
                PhotosPicker(selection: $selectedProfilePicture, matching: .images, photoLibrary: .shared()) {
                    HStack {
                        Text("Change Profile Picture")
                            .font(.system(size: 16, weight: .regular))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.white)
                }
                
                Button(action: {
                    Task {
                        await AuthenticationManager.shared.removeProfilePicture()
                        showProfilePictureOptions = false
                    }
                }) {
                    HStack {
                        Text("Remove Profile Picture")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .background(Color(hex: "F5F5F5"))
        }
        .background(Color.white)
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
    case personalInfo, notifications, privacy, dataUsage, help
    
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
