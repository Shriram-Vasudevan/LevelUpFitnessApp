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
    @State private var showEditNameSheet = false
    @State private var showEditUsernameSheet = false
    @State private var showHelpAndSupportSheet = false
    @State private var selectedProfilePicture: PhotosPickerItem?
    @State private var pfpData: Data?
    @State private var newName: String = ""
    @State private var newUsername: String = ""

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        profileHeader
                        settingsSection
                        supportSection
                        accountActions
                    }
                    .padding()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .accentColor(Color(hex: "40C4FC"))
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task { await AuthenticationManager.shared.deleteUser() }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .sheet(isPresented: $showEditNameSheet, content: {
            editNameSheet
        })
        .sheet(isPresented: $showEditUsernameSheet, content: {
            editUsernameSheet
        })
        .sheet(isPresented: $showHelpAndSupportSheet, content: {
            SupportView()
        })
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
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color(hex: "40C4FC"))
            }
            Spacer()
            Text("Profile")
                .font(.system(size: 18, weight: .semibold))
            Spacer()
        }
        .padding()
        .background(Color.white)
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedProfilePicture, matching: .images, photoLibrary: .shared()) {
                profileImage
            }
            
            Text(authManager.name ?? "Loading...")
                .font(.system(size: 24, weight: .bold))
            
            Text("@\(authManager.username ?? "username")")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.gray)
            
            HStack(spacing: 16) {
                Button(action: { showEditNameSheet = true }) {
                    Text("Edit Name")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "40C4FC"))
                }
                
                Button(action: { showEditUsernameSheet = true }) {
                    Text("Edit Username")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "40C4FC"))
                }
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
    }

    private var profileImage: some View {
        Group {
            if let pfpData = authManager.pfp, let uiImage = UIImage(data: pfpData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image("NoProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 20, weight: .medium))
            
            settingsButton(title: "Notifications", icon: "bell.fill")
            settingsButton(title: "Privacy", icon: "lock.fill")
            settingsButton(title: "Security", icon: "shield.fill")
        }
    }

    private func settingsButton(title: String, icon: String) -> some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "40C4FC"))
                    .frame(width: 30)
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(hex: "F5F5F5"))
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Support")
                .font(.system(size: 20, weight: .medium))
            
            Button(action: { showHelpAndSupportSheet = true }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(Color(hex: "40C4FC"))
                        .frame(width: 30)
                    Text("Help & Support")
                        .font(.system(size: 16, weight: .regular))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(hex: "F5F5F5"))
            }
        }
    }

    private var accountActions: some View {
        VStack(spacing: 16) {
            Button(action: {
                Task { await AuthenticationManager.shared.signOut() }
            }) {
                Text("Sign Out")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
            }
            
            Button(action: { showDeleteConfirmation = true }) {
                Text("Delete Account")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.red)
            }
        }
        .padding(.top, 20)
    }

    private var editNameSheet: some View {
        VStack(spacing: 16) {
            Text("Edit Name")
                .font(.system(size: 18, weight: .semibold))
            
            TextField("New Name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                Task {
                    await authManager.updateName(newName: newName) { success, error in
                        if success { showEditNameSheet = false }
                    }
                }
            }) {
                Text("Save")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
    }

    private var editUsernameSheet: some View {
        VStack(spacing: 16) {
            Text("Edit Username")
                .font(.system(size: 18, weight: .semibold))
            
            TextField("New Username", text: $newUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: {
                Task {
                    await authManager.updateUsername(newUsername: newUsername) { success, error in
                        if success { showEditUsernameSheet = false }
                    }
                }
            }) {
                Text("Save")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white)
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

struct SupportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Help & Support")
                .font(.system(size: 20, weight: .bold))

            Text("For support, please contact us at:")
                .font(.system(size: 16, weight: .regular))
            
            Text("levelupfitttech@gmail.com")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color(hex: "40C4FC"))
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
}

#Preview {
    ProfileView()
}
