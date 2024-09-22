import SwiftUI
import Charts

struct TimeSpentWidget: View {
    var program: Program
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(Color(hex: "40C4FC"))
                
                Text("Average Program Time")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    // Action for "More" button
                }) {
                    HStack {
                        Text("More")
                            .font(.system(size: 14, weight: .medium, design: .default))
                            .foregroundColor(Color(hex: "40C4FC"))
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(hex: "40C4FC"))
                    }
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(String(format: "%.1f", program.getAverageWorkoutTime() / 60))
                    .font(.system(size: 36, weight: .bold, design: .default))
                Text("min")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.gray)
            }
            
            Chart {
                ForEach(program.program, id: \.self) { programDay in
                    LineMark(
                        x: .value("Day", String(programDay.day.prefix(3))),
                        y: .value("Time", programDay.getTotalWorkoutTime() / 60)
                    )
                    .foregroundStyle(Color(hex: "40C4FC").gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...60)
            .frame(height: 60)
        }
        .padding(20)
        .background(Color(hex: "F5F5F5"))
        .overlay(
            Rectangle()
                .fill(Color(hex: "40C4FC"))
                .frame(width: 4)
                .padding(.vertical, 20),
            alignment: .leading
        )
    }
}

#Preview {
    TimeSpentWidget(program: Program(program: [ProgramDay(day: "Monday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Tuesday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Tuesday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Wednesday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Thursday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Friday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Saturday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Sunday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: "5", rpe: "", rest: 3, area: "test", isWeight: false, completed: false, cdnURL: "", equipment: [""], description: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))])], programName: "TestProgram", programDuration: 4, startDate: "", startWeekday: "", environment: ""))
}
