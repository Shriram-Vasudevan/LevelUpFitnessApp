import SwiftUI
import Charts

struct ProgramStatisticsView: View {
    @State var program: Program
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Text("Program Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    
                    Picker("", selection: $selectedTab) {
                        Text("Overview").tag(0)
                        Text("Daily").tag(1)
                        Text("Time").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding([.horizontal, .top])
                    
                    
                    selectedTabContent
                }
            }
            .navigationBarHidden(true)
        }
    }
    

    @ViewBuilder
    private var selectedTabContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                switch selectedTab {
                    case 0: overviewTab
                    case 1: dailyTab
                    case 2: timeTab
                    default: EmptyView()
                }
            }
            .padding()
        }
    }
    
    private var overviewTab: some View {
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                statCard(title: "Program Completion", value: "\(Int(program.getProgramCompletionPercentage()))%", icon: "chart.pie.fill", color: .blue)
                statCard(title: "Total Weight", value: "\(program.getTotalWeightUsed()) kg", icon: "dumbbell.fill", color: .green)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Workout Time")
                    .font(.headline)
                HStack {
                    Gauge(value: program.getTotalWorkoutTime(), in: 0...max(program.getTotalWorkoutTime() + program.getTotalRestTime(), 1)) {
                        Text("Workout")
                    } currentValueLabel: {
                        Text(formatTime(program.getTotalWorkoutTime()))
                    }
                    .gaugeStyle(.accessoryLinear)
                    .tint(.blue)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Top Muscle Groups")
                    .font(.headline)
                
                ForEach(program.getMostFrequentMuscleGroups().prefix(4), id: \.self) { stat in
                    HStack {
                        Text(stat.area)
                        
                        Spacer()
                        
                        Text("\(stat.count)")
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
        }
    }
    
    private var dailyTab: some View {
        VStack(spacing: 20) {
            Chart {
                ForEach(program.getDayCompletionPercentages()) { day in
                    LineMark(
                        x: .value("Day", day.day),
                        y: .value("Completion", day.percentage)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .symbol(Circle().strokeBorder(lineWidth: 2))
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: 0...100)
            
            Text("Daily Completion Percentage")
                .font(.headline)
            
            ForEach(program.getDayCompletionPercentages()) { day in
                HStack {
                    Text(day.day)
                    Spacer()
                    Text("\(Int(day.percentage))%")
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private var timeTab: some View {
        VStack(spacing: 20) {
            statCard(title: "Avg. Rest Differential", value: formatTime(program.getAverageRestDifferential()), icon: "stopwatch", color: .orange)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Rest vs Workout Time")
                    .font(.headline)
                HStack {
                    Gauge(value: program.getTotalRestTime(), in: 0...max(program.getTotalWorkoutTime() + program.getTotalRestTime(), 1)) {
                        Text("Rest")
                    } currentValueLabel: {
                        Text(formatTime(program.getTotalRestTime()))
                    }
                    .gaugeStyle(.accessoryLinear)
                    .tint(.green)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            HStack(spacing: 20) {
                statCard(title: "Total Rest Time", value: formatTime(program.getTotalRestTime()), icon: "bed.double.fill", color: .green)
                statCard(title: "Total Workout Time", value: formatTime(program.getTotalWorkoutTime()), icon: "figure.walk", color: .blue)
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    

    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let remainingSeconds = Int(seconds) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else if minutes > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}

// Add this preview provider at the bottom of your file
#Preview {
    ProgramStatisticsView(program: Program(program: [ProgramDay(day: "", workout: "", completed: false, exercises: [ProgramExercise(name: "", sets: 1, reps: 1, rpe: "", rest: 1, area: "test", completed: false, data: ExerciseData(sets: [ExerciseDataSet(weight: 0, reps: 10, time: 0.0, rest: 0.0)]))])], programName: "", programDuration: 4, startDate: "", startWeekday: ""))
}
