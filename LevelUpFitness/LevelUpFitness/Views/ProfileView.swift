//
//  ProfileView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/6/24.
//

import SwiftUI
import PhotosUI
import CloudKit

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var showDeleteConfirmation = false
    @State private var showEditProfileSheet = false
    @State private var navigateToShowHelpAndSupportView = false
    @State private var selectedProfilePicture: PhotosPickerItem?
    @State private var pfpData: Data?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                supportSection
                accountActions
            }
            .padding()
        }
        .background(Color(hex: "F5F5F5").ignoresSafeArea())
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
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .navigationBarBackButtonHidden()
        .accentColor(Color(hex: "40C4FC"))
        .sheet(isPresented: $showEditProfileSheet) {
            EditProfileView(authManager: authManager)
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle account deletion
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .onChange(of: selectedProfilePicture) { _ in
            Task {
                if let data = try? await selectedProfilePicture?.loadTransferable(type: Data.self) {
                    pfpData = data
                    
                    
                    if let userID = try? await ProgramCloudKitUtility.customContainer.userRecordID().recordName {
                        saveProfilePictureLocally(pfpData: data, userID: userID)
                         authManager.saveOrUpdateUserData(username: nil, name: nil, pfp: data) { _, _ in }
                    }
                }
            }
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedProfilePicture, matching: .images, photoLibrary: .shared()) {
                profileImage
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "40C4FC"), lineWidth: 3)
                    )
                    .shadow(radius: 5)
            }
            
            VStack(spacing: 4) {
                Text(authManager.name ?? "Loading...")
                    .font(.title2.bold())
                
                Text("@\(authManager.username ?? "username")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button(action: { showEditProfileSheet = true }) {
                Text("Edit Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(hex: "F9F9F9"))
        .cornerRadius(10)
    }

    private var profileImage: some View {
        Group {
            if let pfpData = authManager.pfp, let uiImage = UIImage(data: pfpData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else {
                Image("NoProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            }
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.headline)
                .padding(.horizontal)
            
            Button(action: { navigateToShowHelpAndSupportView = true }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(Color(hex: "40C4FC"))
                        .frame(width: 30)
                    Text("Help & Support")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(hex: "F9F9F9"))
        .cornerRadius(10)
    }

    private var accountActions: some View {
        VStack(spacing: 16) {
            Text("Account Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                // Handle sign out
            }) {
                Text("Sign Out")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(10)
            }
            
            Button(action: { showDeleteConfirmation = true }) {
                Text("Delete Account")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(hex: "F9F9F9"))
        .cornerRadius(10)
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
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    Task {
                        if newName != authManager.name {
                            authManager.saveOrUpdateUserData(username: nil, name: newName, pfp: nil) { _, _ in }
                        }
                        if newUsername != authManager.username {
                            authManager.saveOrUpdateUserData(username: newUsername, name: nil, pfp: nil) { _, _ in }
                        }
                        dismiss()
                    }
                }
            )
        }
        .accentColor(Color(hex: "40C4FC"))
        .onAppear {
            newName = authManager.name ?? ""
            newUsername = authManager.username ?? ""
        }
    }
}

struct SupportView: View {
    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    contactInfo(title: "Email", value: "levelupfitnesshelp@gmail.com", icon: "envelope.fill")
                    contactInfo(title: "Website", value: "www.levelupfitness.app", icon: "globe")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Spacer()
                
                Text("Icons by Icons8")
                    .font(.footnote)
                    .foregroundColor(.secondary)
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
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundColor(Color(hex: "40C4FC"))
            }
            Spacer()
        }
    }
}
#Preview {
    ProfileView()
}
