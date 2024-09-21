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
            Color.white
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Exercise")
                                    .font(.system(size: 28, weight: .medium, design: .default))
                                    .foregroundColor(.black)
                                Text("Discover and master new exercises.")
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.top, 15)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Custom Workouts")
                                .font(.system(size: 22, weight: .medium, design: .default))
                                .foregroundColor(.black)
                            Spacer()
                            
                            Button {
                                navigateToCustomWorkoutCreation = true
                            } label: {
                                Text("Create New")
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(Color(hex: "40C4FC"))
                            }

                        }
                        
                        if customWorkoutsManager.customWorkouts.isEmpty {
                            Text("No Custom Workouts. Create one!")
                                .font(.system(size: 16, weight: .regular, design: .default))
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false)
                            {
                                HStack(spacing: 16) {
                                    ForEach(customWorkoutsManager.customWorkouts, id: \.name) { workout in
                                        CustomWorkoutWidget(workout: workout) { workoutToDelete in
                                            customWorkoutsManager.deleteCustomWorkout(workout: workoutToDelete)
                                        }
                                        .onTapGesture {
                                            selectedCustomWorkout = workout
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if let userXPData = xpManager.userXPData {
                        ForEach(exerciseTypeKeys, id: \.self) { key in
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Text(key.capitalizingFirstLetter())
                                        .font(.system(size: 22, weight: .medium, design: .default))
                                        .foregroundColor(.black)
                                    Spacer()
                                    if let level = userXPData.subLevels.attribute(for: key)?.level {
                                        Text("Level \(level)")
                                            .font(.system(size: 14, weight: .medium, design: .default))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(Color(hex: "40C4FC"))
                                    }
                                }
                                
                                let filteredExercises = exerciseManager.exercises.filter { $0.exerciseType == key.capitalizingFirstLetter() }
                                if filteredExercises.isEmpty {
                                    Text("No exercises for \(key)")
                                        .foregroundColor(.gray)
                                } else {
                                    ForEach(filteredExercises, id: \.id) { exercise in
                                        ExerciseLibraryExerciseWidget(exercise: exercise, userXPData: userXPData) { progression in
                                            self.selectedExercise = progression
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(item: $selectedExercise) { exercise in
            IndividualExerciseView(progression: exercise)
        }
        .fullScreenCover(isPresented: $navigateToCustomWorkoutCreation, content: {
            CreateCustomWorkoutView()
        })
        .fullScreenCover(item: $selectedCustomWorkout) { selectedCustomWorkout in
            CustomWorkoutView(workout: selectedCustomWorkout)
        }
    }
}

#Preview {
    LibraryView(programManager: ProgramManager(), xpManager: XPManager(), exerciseManager: ExerciseManager())
}
