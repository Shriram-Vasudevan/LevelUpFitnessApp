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

    @State var goBackToIntroView: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                profileHeader
                Divider()
                supportSection
                Divider()
                accountActions
            }
            .padding()
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(hex: "40C4FC"))
                        .imageScale(.large)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showEditProfileSheet) {
            EditProfileView(authManager: authManager)
        }
        .alert("Delete Account", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                AuthenticationManager.shared.deleteUserData { success, error in
                    if success {
                        FirstLaunchManager.shared.isFirstLaunch = true
                        goBackToIntroView = true
                    }
                }
            }
        } message: {
            Text("Are you sure you want to wipe your data? You will still be able to use this iCloud account for future use, but all existing data will be wiped. This action cannot be undone.")
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
        .navigationDestination(isPresented: $goBackToIntroView) {
            OpeningViewsContainer()
        }
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            PhotosPicker(selection: $selectedProfilePicture, matching: .images, photoLibrary: .shared()) {
                profileImage
                    .overlay(
                        Circle()
                            .stroke(Color(hex: "40C4FC"), lineWidth: 2)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            
            VStack(spacing: 4) {
                Text(authManager.name ?? "...")
                    .font(.title3.bold())
                
                Text("@\(authManager.username ?? "...")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Button(action: { showEditProfileSheet = true }) {
                Text("Edit Profile")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .frame(height: 36)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(10)
            }
        }
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

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Support")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: { navigateToShowHelpAndSupportView = true }) {
                HStack {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundColor(Color(hex: "40C4FC"))
                    Text("Help & Support")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
        }
    }

    private var accountActions: some View {
        VStack(spacing: 16) {
            Text("Account Actions")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                AuthenticationManager.shared.signOut { success in
                    if success {
                        FirstLaunchManager.shared.isFirstLaunch = true
                        goBackToIntroView = true
                    }
                }
            }) {
                Text("Sign Out")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(10)
            }
            
            Button(action: { showDeleteConfirmation = true }) {
                Text("Wipe Data")
                    .font(.footnote)
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
            Form {
                Section(header: Text("Profile Information").textCase(.uppercase).font(.footnote).foregroundColor(.secondary)) {
                    HStack {
                        TextField("Name", text: $newName)
                        Image(systemName: "pencil")
                            .foregroundColor(Color(hex: "40C4FC"))
                            .font(.caption)
                    }
                    HStack {
                        TextField("Username", text: $newUsername)
                        Image(systemName: "pencil")
                            .foregroundColor(Color(hex: "40C4FC"))
                            .font(.caption)
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
        List {
            Section {
                contactInfo(title: "Email", value: "levelupfitnesshelp@gmail.com", icon: "envelope.fill")
                contactInfo(title: "Website", value: "www.levelupfitness.app", icon: "globe")
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Help & Support", displayMode: .inline)
        .background(Color(hex: "F5F5F5").ignoresSafeArea())
    }
    
    private func contactInfo(title: String, value: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "40C4FC"))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView()
}
