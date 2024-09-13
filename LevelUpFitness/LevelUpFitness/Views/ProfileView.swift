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
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(Color(hex: "40C4FC"))
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    
                    Text("Profile")
                        .font(.system(size: 28, weight: .medium, design: .default))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .padding(.bottom, 10)
                
                ScrollView {
                    VStack(spacing: 30) {
                        profileHeader
                        settingsSection
                        accountActions
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarBackButtonHidden()
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
        VStack(spacing: 20) {
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
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            VStack(spacing: 8) {
                Text(authManager.username ?? "Checking")
                    .font(.custom("Poppins-SemiBold", size: 24))
                    .foregroundColor(Color(hex: "333333"))
                Text(authManager.name ?? "Checking")
                    .font(.custom("Poppins-Regular", size: 18))
                    .foregroundColor(Color(hex: "666666"))
            }
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.custom("Poppins-SemiBold", size: 22))
                .foregroundColor(Color(hex: "333333"))
                .padding(.leading, 8)
            
            ForEach(SettingsOption.allCases, id: \.self) { option in
                Button(action: { }) {
                    HStack {
                        Image(systemName: option.iconName)
                            .foregroundColor(Color(hex: "40C4FC"))
                            .frame(width: 30)
                        
                        Text(option.title)
                            .font(.custom("Poppins-Medium", size: 16))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(hex: "CCCCCC"))
                    }
                }
                .foregroundColor(Color(hex: "333333"))
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private var accountActions: some View {
        VStack(spacing: 20) {
            Button(action: {
                Task {
                    await AuthenticationManager.shared.signOut()
                }
            }) {
                Text("Sign Out")
                    .font(.custom("Poppins-SemiBold", size: 18))
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
                    .font(.custom("Poppins-Medium", size: 16))
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var profilePictureOptionsSheet: some View {
        VStack(spacing: 20) {
            PhotosPicker(selection: $selectedProfilePicture, matching: .images, photoLibrary: .shared()) {
                Text("Change Profile Picture")
                    .font(.custom("Poppins-Medium", size: 18))
                    .foregroundColor(Color(hex: "40C4FC"))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "40C4FC").opacity(0.1))
                    .cornerRadius(15)
            }
            
            Button(action: {
                Task {
                    await AuthenticationManager.shared.removeProfilePicture()
                    showProfilePictureOptions = false
                }
            }) {
                Text("Remove Profile Picture")
                    .font(.custom("Poppins-Medium", size: 18))
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(15)
            }
        }
        .padding(24)
        .background(Color.white)
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
