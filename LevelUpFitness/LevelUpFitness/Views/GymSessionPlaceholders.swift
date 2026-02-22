//
//  GymSessionPlaceholders.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

struct GymSessionExerciseView: View {
    var exerciseRecord: ExerciseRecord
    var body: some View {
        ZStack { AppTheme.Colors.backgroundDark.ignoresSafeArea() }
        .navigationTitle("Exercise Detail")
    }
}

struct PastGymSessionDetailView: View {
    let session: GymSession
    var body: some View {
        ZStack { AppTheme.Colors.backgroundDark.ignoresSafeArea() }
        .navigationTitle("Session Detail")
    }
}

struct AddExerciseView: View {
    let onAddExercise: (ExerciseRecord) -> Void
    var body: some View {
        ZStack { AppTheme.Colors.backgroundDark.ignoresSafeArea() }
        .navigationTitle("Add Exercise")
    }
}

struct AllPastGymSessionsView: View {
    @ObservedObject var gymManager: GymManager
    var body: some View {
        ZStack { AppTheme.Colors.backgroundDark.ignoresSafeArea() }
        .navigationTitle("All Sessions")
    }
}

struct GymSessionInfoView: View {
    var body: some View {
        ZStack { AppTheme.Colors.backgroundDark.ignoresSafeArea() }
        .navigationTitle("Session Info")
    }
}
