import SwiftUI
import Charts

struct TimeSpentWidget: View {
    var program: Program
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.primary)
                
                Text("Average Program Time")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    HStack {
                        Text("More")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                    }
                }
            }
            .padding(.bottom, 5)
            
            Text(String(format: "%.1f", program.getAverageWorkoutTime() / 60))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                + Text(" min")
                .font(.system(size: 20, weight: .medium, design: .rounded))
            
            Text("Average")
                .foregroundColor(.gray)
                .padding(.bottom, 10)
            
            Chart {
                ForEach(program.program, id: \.self) { programDay in
                    LineMark(
                        x: .value("Day", String(programDay.day.prefix(3))),
                        y: .value("Time", programDay.getTotalWorkoutTime() / 60)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartYScale(domain: 0...60)
            .frame(height: 70) // Reduced height from 100 to 70
            .padding(.horizontal)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    TimeSpentWidget(program: Program(program: [ProgramDay(day: "Monday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Tuesday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Tuesday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Wednesday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Thursday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Friday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Saturday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Sunday", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", isWeight: false, completed: false, CDNURL: "", data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))])], programName: "TestProgram", programDuration: 4, startDate: "", startWeekday: ""))
}
