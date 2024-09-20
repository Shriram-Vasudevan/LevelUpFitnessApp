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
    @State private var showEditNameSheet = false
    @State private var showEditUsernameSheet = false
    @State private var showHelpAndSupportSheet = false
    @State private var selectedProfilePicture: PhotosPickerItem?
    @State private var pfpData: Data?
    @State private var newName: String = ""
    @State private var newUsername: String = ""

    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                VStack(spacing: 16) {
                    profileHeader
                    supportSection
                    accountActions
                    
                    Spacer()
                    
                    icons8Attribution
                }
                .padding()
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
        .sheet(isPresented: $showEditNameSheet, content: {
            editNameSheet
        })
        .sheet(isPresented: $showEditUsernameSheet, content: {
            editUsernameSheet
        })
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
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "40C4FC"), lineWidth: 2))
                } else {
                    Image("NoProfile")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color(hex: "40C4FC"), lineWidth: 2))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(authManager.name ?? "Loading...")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .onTapGesture {
                        showEditNameSheet = true
                    }
                Text(authManager.username ?? "Loading...")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .onTapGesture {
                        showEditUsernameSheet = true
                    }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    private var supportSection: some View {
        VStack(spacing: 16) {
            Button(action: { showHelpAndSupportSheet = true }) {
                VStack {
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
                    .background(Color.white)
                }
            }
            .foregroundColor(.black)
            .sheet(isPresented: $showHelpAndSupportSheet) {
                SupportView()
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
                    .cornerRadius(8)
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
    
    private var editNameSheet: some View {
        VStack {
            TextField("New Name", text: $newName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }

    private var editUsernameSheet: some View {
        VStack {
            TextField("New Username", text: $newUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC"))
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
    
    private var icons8Attribution: some View {
        VStack {
            Text("Icons by Icons8")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
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

struct SupportView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Help & Support")
                .font(.system(size: 20, weight: .bold))
                .padding()

            Text("For support, please contact us at:")
                .font(.system(size: 16, weight: .regular))
            
            Text("levelupfitttech@gmail.com")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
    }
}


#Preview {
    ProfileView()
}
