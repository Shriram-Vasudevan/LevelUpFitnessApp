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
    @State private var navigateToShowHelpAndSupportView = false
    @State private var selectedProfilePicture: PhotosPickerItem?
    @State private var pfpData: Data?

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        profileHeader
                        supportSection
                        accountActions
                    }
                    .padding(.horizontal)
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
        .fullScreenCover(isPresented: $showEditProfileSheet) {
            EditProfileView(authManager: authManager)
        }
        .navigationDestination(isPresented: $navigateToShowHelpAndSupportView) {
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
        ZStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "40C4FC"))
                }
                Spacer()
            }
            
            Text("Profile")
                .font(.system(size: 18, weight: .semibold))
        }
        .padding()
        .background(Color.white)
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedProfilePicture, matching: .images, photoLibrary: .shared()) {
                profileImage
            }
            
            VStack(spacing: 5) {
                Text(authManager.name ?? "Loading...")
                    .font(.system(size: 24, weight: .bold))
                
                Text("@\(authManager.username ?? "username")")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
            }
            
            Button(action: { showEditProfileSheet = true }) {
                Text("Edit Profile")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
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

    private func menuItem(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.system(size: 20, weight: .medium))
            
            Button(action: { navigateToShowHelpAndSupportView = true }) {
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
        VStack(spacing: 12) {
            Text("Account Actions")
                .font(.system(size: 20, weight: .medium))
            
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
            VStack {
                Form {
                    Section(header: Text("Profile Information")) {
                        HStack {
                            TextField("Name", text: $newName)
                            Image(systemName: "pencil")
                                .foregroundColor(Color(hex: "40C4FC"))
                        }
                        HStack {
                            TextField("Username", text: $newUsername)
                            Image(systemName: "pencil")
                                .foregroundColor(Color(hex: "40C4FC"))
                        }
                    }
                }
                .onAppear {
                    newName = authManager.name ?? ""
                    newUsername = authManager.username ?? ""
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    Task {
                        if newName != authManager.name {
                            await authManager.updateName(newName: newName) { _, _ in }
                        }
                        if newUsername != authManager.username {
                            await authManager.updateUsername(newUsername: newUsername) { _, _ in }
                        }
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
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    contactInfo(title: "Email", value: "levelupfitttech@gmail.com", icon: "envelope.fill")
                    contactInfo(title: "Website", value: "www.levelupfitness.com", icon: "globe")
                }
                .padding()
                .background(Color.white)
                
                Spacer()
                
                Text("Icons by Icons8")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
        }
        .navigationBarTitle("Help & Support", displayMode: .inline)
    }
    
    private func contactInfo(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "40C4FC"))
                .frame(width: 30)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "40C4FC"))
            }
            Spacer()
        }
    }
}
#Preview {
    ProfileView()
}
