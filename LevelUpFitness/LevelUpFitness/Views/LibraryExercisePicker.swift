//
//  LibraryExercisePicker.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

struct LibraryExercisePicker: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var exerciseManager = ExerciseManager.shared
    
    var onSelect: (Progression) -> Void
    
    @State private var searchText = ""
    
    var filteredExercises: [ExerciseLibraryExercise] {
        if searchText.isEmpty {
            return exerciseManager.exercises
        } else {
            return exerciseManager.exercises.compactMap { group in
                let matchingProgressions = group.progression.filter { progression in
                    progression.name.localizedCaseInsensitiveContains(searchText) ||
                    progression.exerciseType.localizedCaseInsensitiveContains(searchText)
                }
                
                if !matchingProgressions.isEmpty {
                    var newGroup = group
                    newGroup.progression = matchingProgressions
                    return newGroup
                }
                return nil
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Colors.backgroundDark.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 24, pinnedViews: .sectionHeaders) {
                        ForEach(filteredExercises, id: \.id) { group in
                            Section {
                                VStack(spacing: 8) {
                                    ForEach(group.progression, id: \.name) { progression in
                                        Button(action: {
                                            onSelect(progression)
                                            dismiss()
                                        }) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(progression.name)
                                                        .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                                                        .foregroundColor(AppTheme.Colors.textPrimary)
                                                    
                                                    HStack(spacing: 6) {
                                                        Image(systemName: progression.isWeight ? "dumbbell.fill" : "figure.walk")
                                                            .font(.system(size: 10))
                                                        Text(progression.isWeight ? "Weighted" : "Bodyweight")
                                                    }
                                                    .font(AppTheme.Typography.telemetry(size: 12))
                                                    .foregroundColor(AppTheme.Colors.textSecondary)
                                                }
                                                
                                                Spacer()
                                                
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(AppTheme.Colors.bluePrimary)
                                            }
                                            .padding(16)
                                            .background(AppTheme.Colors.surfaceLight)
                                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(KineticButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            } header: {
                                HStack {
                                    Text(group.name) // or group.exerciseType depending on how you group
                                        .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.Colors.textSecondary)
                                        .textCase(.uppercase)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(AppTheme.Colors.backgroundDark) // sticky header background
                            }

                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Exercise Library")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.Colors.textSecondary)
                            .font(.system(size: 24))
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search exercises...")
            .preferredColorScheme(.dark)
        }
    }
}
