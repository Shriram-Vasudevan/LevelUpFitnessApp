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
    @State private var showEditProfileSheet = false
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
                    VStack(spacing: 20) {
                        profileHeader
                        statsSection
                        menuSection
                        collectionSection
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
        .sheet(isPresented: $showEditProfileSheet) {
            EditProfileView(authManager: authManager)
        }
        .sheet(isPresented: $showHelpAndSupportSheet) {
            SupportView()
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
            
            Button(action: { showEditProfileSheet = true }) {
                Text("Edit Profile")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(22)
            }
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(10)
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

    private var statsSection: some View {
        HStack(spacing: 30) {
            statItem(title: "Streak", value: "1")
            statItem(title: "Badges", value: "None", showArrow: true)
            statItem(title: "Coins", value: "0", icon: "dollarsign.circle.fill", showArrow: true)
        }
        .padding()
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(10)
    }

    private func statItem(title: String, value: String, icon: String? = nil, showArrow: Bool = false) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.gray)
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: "40C4FC"))
                }
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                if showArrow {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.gray)
                }
            }
        }
    }

    private var menuSection: some View {
        VStack(spacing: 0) {
            menuItem(title: "About", action: {})
            menuItem(title: "Upvoted", action: {})
            menuItem(title: "Hunted", action: {})
            menuItem(title: "Collected", action: {}, isSelected: true)
        }
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(10)
    }

    private func menuItem(title: String, action: @escaping () -> Void, isSelected: Bool = false) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? Color(hex: "40C4FC") : .gray)
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(isSelected ? Color(hex: "40C4FC").opacity(0.1) : Color.clear)
        }
    }

    private var collectionSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No collections here yet")
                .font(.system(size: 18, weight: .semibold))
            
            Text("Looks like you don't have any collections here yet,")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Button(action: { /* Add action to create collection */ }) {
                Text("create one")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "40C4FC"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "F5F5F5"))
        .cornerRadius(10)
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
                .cornerRadius(10)
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
                    .cornerRadius(25)
            }
            
            Button(action: { showDeleteConfirmation = true }) {
                Text("Delete Account")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.red)
            }
        }
        .padding(.top, 20)
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

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var authManager: AuthenticationManager
    @State private var newName: String = ""
    @State private var newUsername: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Information")) {
                    TextField("Name", text: $newName)
                    TextField("Username", text: $newUsername)
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    Task {
                        await authManager.updateName(newName: newName) { _, _ in }
                        await authManager.updateUsername(newUsername: newUsername) { _, _ in }
                        dismiss()
                    }
                }
            )
        }
        .accentColor(Color(hex: "40C4FC"))
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
