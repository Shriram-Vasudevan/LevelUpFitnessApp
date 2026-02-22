//
//  LibraryView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var xpManager: XPManager
    @ObservedObject var exerciseManager: ExerciseManager
    @ObservedObject var customWorkoutsManager = CustomWorkoutManager.shared
    
    @State var selectedExercise: Progression?
    @State var selectedCustomWorkout: CustomWorkout?
    @State var navigateToCustomWorkout: Bool = false
    @State var navigateToCustomWorkoutCreation: Bool = false
    
    let exerciseTypeKeys = [
        Sublevels.CodingKeys.lowerBodyCompound.rawValue,
        Sublevels.CodingKeys.lowerBodyIsolation.rawValue,
        Sublevels.CodingKeys.upperBodyCompound.rawValue,
        Sublevels.CodingKeys.upperBodyIsolation.rawValue
    ]
    
    var body: some View {
        ZStack {
            AppTheme.Colors.backgroundDark.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    headerSection
                    customWorkoutsSection
                    
                    if let _ = xpManager.userXPData {
                        exerciseMasterGrid
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .padding(.bottom, 120) // Tab bar clearance
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(item: $selectedExercise) { exercise in
            IndividualExerciseView(progression: exercise)
        }
        .fullScreenCover(isPresented: $navigateToCustomWorkoutCreation) {
            CreateCustomWorkoutView()
        }
        .fullScreenCover(item: $selectedCustomWorkout) { workout in
            CustomWorkoutView(workout: workout)
        }
    }

    // MARK: - App Architecture Components
    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Library")
                    .font(AppTheme.Typography.telemetry(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                Text("Master the mechanics.")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
            Spacer()
        }
    }

    private var customWorkoutsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Custom Sequences")
                    .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .textCase(.uppercase)
                
                Spacer()
                
                Button(action: { navigateToCustomWorkoutCreation = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.Colors.bluePrimary)
                        .frame(width: 32, height: 32)
                        .background(AppTheme.Colors.bluePrimary.opacity(0.1))
                        .clipShape(Circle())
                }
                .buttonStyle(KineticButtonStyle())
            }
            
            if customWorkoutsManager.customWorkouts.isEmpty {
                Button(action: { navigateToCustomWorkoutCreation = true }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.squares")
                            .font(.system(size: 24))
                        Text("Create Sequence")
                            .font(AppTheme.Typography.telemetry(size: 14, weight: .bold))
                    }
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                    .background(AppTheme.Colors.surfaceLight)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous)
                            .stroke(Color.black.opacity(0.04), style: StrokeStyle(lineWidth: 1, dash: [4]))
                    )
                }
                .buttonStyle(KineticButtonStyle())
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(customWorkoutsManager.customWorkouts, id: \.name) { workout in
                            Button(action: { selectedCustomWorkout = workout }) {
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack(alignment: .top) {
                                        Image(systemName: "square.stack.3d.up.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppTheme.Colors.bluePrimary)
                                        Spacer()
                                        Button(action: { customWorkoutsManager.deleteCustomWorkout(workout: workout) }) {
                                            Image(systemName: "trash.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))
                                                .padding(8)
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(workout.name)
                                            .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
                                            .foregroundColor(AppTheme.Colors.textPrimary)
                                            .lineLimit(2)
                                        Text("\(workout.exercises.count) Modules")
                                            .font(AppTheme.Typography.telemetry(size: 12, weight: .bold))
                                            .foregroundColor(AppTheme.Colors.textSecondary)
                                    }
                                }
                                .padding(16)
                                .frame(width: 160, height: 160)
                                .background(AppTheme.Colors.surfaceLight)
                                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous))
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(KineticButtonStyle())
                        }
                    }
                }
            }
        }
    }

    private var exerciseMasterGrid: some View {
        VStack(alignment: .leading, spacing: 24) {
            ForEach(exerciseTypeKeys, id: \.self) { categoryKey in
                let categoryName = categoryKey.capitalizingFirstLetter()
                let filteredExercises = exerciseManager.exercises.filter { $0.exerciseType == categoryName }
                let userLevel = xpManager.userXPData?.subLevels.attribute(for: categoryKey)?.level ?? 1
                
                if !filteredExercises.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .bottom) {
                            Text(categoryName)
                                .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text("Lvl")
                                    .font(AppTheme.Typography.telemetry(size: 10, weight: .bold))
                                Text("\(userLevel)")
                                    .font(AppTheme.Typography.monumentalNumber(size: 14))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(AppTheme.Colors.bluePrimary)
                            .clipShape(Capsule())
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(filteredExercises, id: \.id) { exercise in
                                if let xpData = xpManager.userXPData {
                                    ExerciseLibraryExerciseWidget(
                                        exercise: exercise,
                                        userXPData: xpData,
                                        exerciseSelected: { progression in
                                            selectedExercise = progression
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    LibraryView(programManager: ProgramManager(), xpManager: XPManager(), exerciseManager: ExerciseManager())
}
