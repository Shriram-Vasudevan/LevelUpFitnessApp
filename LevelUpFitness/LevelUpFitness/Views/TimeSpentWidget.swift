import SwiftUI
import Charts

struct TimeSpentWidget: View {
    var program: Program
    
    var body: some View {
        VStack (spacing: 10){
            HStack {
                Text("Time Spent Exercising")
                    .font(.custom("EtruscoNowCondensed Bold", size: 20))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button {
                    // Add action here
                } label: {
                    HStack {
                        Text("View more Analytics")
                            .font(.caption)
                            .foregroundColor(.black)
                        
                        Image(systemName: "chevron.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 5)
                            .foregroundColor(.black)
                    }
                }
            }
            
            GeometryReader { geometry in
                HStack {
                    StatisticsWidget(width: geometry.size.width / 3, colorA: .blue, colorB: .cyan, stat: program.getAverageWorkoutTime() / 60, text: "min. average")
                    
                    Chart {
                        ForEach(program.program, id: \.self) { programDay in
                            LineMark (
                                x: .value("Day", String(programDay.day.prefix(3))),
                                y: .value("Time", programDay.getTotalWorkoutTime() / 60)
                            )
                            .foregroundStyle(.blue)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                            .symbol(Circle().strokeBorder(lineWidth: 2))
                        }
                    }
                    .chartXAxis {
                        AxisMarks(preset: .aligned, position: .bottom, values: .automatic)
                    }
                    .chartYAxis {
                        AxisMarks(preset: .aligned, position: .leading, values: .automatic)
                    }
                    .chartYScale(domain: 0...60)
                    .frame(height: geometry.size.width / 3)
         
                }
            }
            .frame(height: UIScreen.main.bounds.height / 8)
            
        }
        .padding(.top, 5)
        .padding([.horizontal, .bottom])
        .background(
            RoundedRectangle(cornerRadius: 7)
                .fill(Color.white)
        )
        .padding()
        
    }
}


#Preview {
    TimeSpentWidget(program: Program(program: [ProgramDay(day: "Monday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Tuesday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Wednesday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Thursday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Friday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Saturday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))]),
                                               ProgramDay(day: "Sunday", workout: "", completed: false, exercises: [Exercise(name: "", sets: 2, reps: 5, rpe: "", rest: 3, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 1, time: 0.0, rest: 0.0)]))])], programName: "TestProgram"))
}
