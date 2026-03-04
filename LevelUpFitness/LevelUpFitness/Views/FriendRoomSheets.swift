//
//  FriendRoomSheets.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

struct CreateFriendRoomSheet: View {
    let context: FriendWorkoutContext
    let onCreate: (String, Date, Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var roomTitle: String = ""
    @State private var scheduleDate: Date = Date()
    @State private var isPublic: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.backgroundDark.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    EngineeredTextField(title: "Team Session Name", text: $roomTitle, placeholder: "e.g. Morning Lift", icon: "shield.fill")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Synchronization Time")
                            .font(AppTheme.Typography.telemetry(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .textCase(.uppercase)
                        
                        DatePicker("", selection: $scheduleDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .padding()
                            .background(AppTheme.Colors.surfaceLight)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    KineticToggle(title: "Public Recruitment", isOn: $isPublic)
                    
                    Spacer()
                    
                    PremiumActionButton(title: "Initialize Room", icon: "network", action: {
                        onCreate(roomTitle.isEmpty ? "Team Session" : roomTitle, scheduleDate, isPublic)
                        dismiss()
                    }, style: .primary)
                }
                .padding(20)
            }
            .navigationTitle("Create Team")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct GlobalFriendRoomDirectorySheet: View {
    let initialContext: FriendWorkoutContext
    let onJoinComplete: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var friendWorkoutManager = FriendWorkoutManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if friendWorkoutManager.globalRooms.isEmpty {
                            Text("No open sessions detected.")
                                .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .padding(.top, 40)
                        } else {
                            ForEach(friendWorkoutManager.globalRooms) { room in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(room.title)
                                            .font(AppTheme.Typography.telemetry(size: 16, weight: .bold))
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                        Text(room.scheduleDate, style: .date)
                                            .font(AppTheme.Typography.telemetry(size: 12, weight: .medium))
                                            .foregroundColor(AppTheme.Colors.bluePrimary)
                                    }
                                    Spacer()
                                    Button(action: {
                                        joinRoomAndDismiss(roomCode: room.roomCode)
                                    }) {
                                        Text("JOIN")
                                            .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(AppTheme.Colors.bluePrimary)
                                            .clipShape(Capsule())
                                    }
                                }
                                .padding(16)
                                .background(AppTheme.Colors.surfaceLight)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous))
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Global Directory")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                    }
                }
            }
            .task {
                await friendWorkoutManager.refreshIfNeeded(context: initialContext)
            }
        }
    }
    
    private func joinRoomAndDismiss(roomCode: String) {
        Task {
            let success = await friendWorkoutManager.joinRoom(withCode: roomCode)
            await MainActor.run {
                onJoinComplete(success ? "Joined session." : "Failed to join.")
                dismiss()
            }
        }
    }
}
