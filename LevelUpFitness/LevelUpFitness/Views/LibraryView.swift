import SwiftUI

struct LibraryView: View {
    @ObservedObject var programManager: ProgramManager
    @ObservedObject var xpManager: XPManager
    @ObservedObject var exerciseManager: ExerciseManager
    
    @State var selectedExercise: Progression?
    @State private var searchText = ""
    
    let exerciseTypeKeys = [
        Sublevels.CodingKeys.lowerBodyCompound.rawValue,
        Sublevels.CodingKeys.lowerBodyIsolation.rawValue,
        Sublevels.CodingKeys.upperBodyCompound.rawValue,
        Sublevels.CodingKeys.upperBodyIsolation.rawValue
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        VStack (spacing: 10) {
                            VStack (spacing: 3) {
                                HStack {
                                    VStack (alignment: .leading, spacing: 4){
                                        HStack {
                                            Text("Exercise Library")
                                                .font(.custom("Sailec Medium", size: 30))
                                        }
                                        
                                        Text("Discover and master new exercises.")
                                            .font(.custom("Sailec Regular Italic", size: 12))
                                    }
                                    
                                    Spacer()
                                    
                                    
                                }
                            }
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                TextField("Search exercises", text: $searchText)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        
                        if let featuredProgressions = getFeaturedProgressions() {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Featured Exercises")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "1E293B"))
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(featuredProgressions, id: \.name) { progression in
                                            FeaturedExerciseCard(progression: progression)
                                                .padding(.vertical, 3)
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
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(hex: "1E293B"))
                                        Spacer()
                                        if let level = userXPData.subLevels.attribute(for: key)?.level {
                                            Text("Level \(level)")
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color(hex: "3B82F6"))
                                                .cornerRadius(20)
                                        }
                                    }
                                    
                                    let filteredExercises = exerciseManager.exercises.filter { $0.exerciseType == key.capitalizingFirstLetter() }
                                    if filteredExercises.isEmpty {
                                        Text("No exercises for \(key)")
                                            .foregroundColor(.secondary)
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
            .navigationDestination(item: $selectedExercise) { exercise in
                IndividualExerciseView(progression: exercise)
            }
        }
    }
    
    func getFeaturedProgressions() -> [Progression]? {
        var featuredProgressions: [Progression] = []
        
        for key in exerciseTypeKeys {
            if let userXPData = xpManager.userXPData, let level = userXPData.subLevels.attribute(for: key)?.level {
                
                let availableExercises = exerciseManager.exercises.filter { $0.exerciseType == key.capitalizingFirstLetter() }
                
                for exercise in availableExercises {
                    for progression in exercise.progression {
                        if level == progression.level {
                            featuredProgressions.append(progression)
                        }
                    }
                    
                }
                
            }
        }
        
        featuredProgressions = featuredProgressions.sorted(by: { $0.level > $1.level })
        
        return featuredProgressions.count == 0 ? nil : Array(featuredProgressions.shuffled().prefix(5))
    }

}

struct FeaturedExerciseCard: View {
    var progression: Progression
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image("FeaturedExercise")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 200, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Text("Featured Exercise")
                .font(.headline)
                .foregroundColor(Color(hex: "1E293B"))
            
            Text(progression.name)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(width: 200)
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    LibraryView(programManager: ProgramManager(), xpManager: XPManager(), exerciseManager: ExerciseManager())
}
