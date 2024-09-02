import SwiftUI

struct UpNextProgramExerciseWidget: View {
    @ObservedObject var programManager: ProgramManager
    @Binding var navigateToWorkoutView: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerView
            
            if let todaysProgram = programManager.program?.program.first(where: { $0.day == getCurrentWeekday() }),
               let (_, nextExercise) = todaysProgram.exercises.enumerated().first(where: { !$0.element.completed }) {
                exerciseDetailsView(for: nextExercise)
            } else {
                noWorkoutView
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(colorScheme == .dark ? Color.black : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.bottom)
        .onTapGesture {
            withAnimation(.spring()) {
                navigateToWorkoutView = true
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Up Next")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right.circle.fill")
                .foregroundColor(.blue)
                .font(.system(size: 24))
        }
    }
    
    private func exerciseDetailsView(for exercise: ProgramExercise) -> some View {
        HStack(spacing: 20) {
            exerciseIcon(for: exercise)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                detailsView(for: exercise)
            }
        }
    }
    
    private func exerciseIcon(for exercise: ProgramExercise) -> some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 60, height: 60)
            
            Image(systemName: exercise.isWeight ? "dumbbell.fill" : "figure.walk")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
        }
    }
    
    private func detailsView(for exercise: ProgramExercise) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                detailItem(title: "Sets", value: "\(exercise.sets)")
                detailItem(title: "Reps", value: "\(exercise.reps)")
            }
            
            HStack(spacing: 12) {
                detailItem(title: "RPE", value: "\(exercise.rpe)")
                detailItem(title: "Rest", value: "\(exercise.rest)s")
            }
        }
    }
    
    private func detailItem(title: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var noWorkoutView: some View {
        Text("No workout for today")
            .foregroundColor(.secondary)
            .font(.subheadline)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
    }
    
    private func getCurrentWeekday() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
    }
}

struct UpNextProgramExerciseWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UpNextProgramExerciseWidget(programManager: ProgramManager(), navigateToWorkoutView: .constant(false))
                .previewDisplayName("Light Mode")
            
            UpNextProgramExerciseWidget(programManager: ProgramManager(), navigateToWorkoutView: .constant(false))
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
