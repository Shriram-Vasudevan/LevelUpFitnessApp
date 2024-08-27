import SwiftUI
import Charts

struct WeightTrendView: View {
    @ObservedObject var trendManager = TrendManager.shared
    @State var weight: String = ""
    
    @State var maxValue: Double = 0
    @State var minDate: Date = Date()
    @State var maxDate: Date = Date()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Weight Trend")
                        .font(.title)
                        .bold()
                    
                    Spacer()
                    
                    Button {
                        if let weight = Double(weight) {
                            Task {
                                await trendManager.addWeightToTrend(weight: weight)
                                self.weight = ""
                                await updateChartData()
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 23, height: 23)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                TextField("", text: $weight)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .font(Font.system(size: 22, design: .rounded))
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                
                if trendManager.weightTrend.count > 0 {
                    Chart(trendManager.weightTrend) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Weight", dataPoint.value)
                        )
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Weight", dataPoint.value)
                        )
                    }
                    .chartXScale(domain: minDate...maxDate)
                    .chartYScale(domain: 0...maxValue)
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            Task {
                await updateChartData()
            }
        }
    }
    
    func updateChartData() async {
        if TrendManager.shared.weightTrend.isEmpty {
            await TrendManager.shared.getWeightTrend()
        }
        
        let sortedTrend = TrendManager.shared.weightTrend.sorted { $0.date < $1.date }
        
        maxValue = (sortedTrend.map { $0.value }.max() ?? 200) * 1.1
        minDate = sortedTrend.first?.date ?? Date()
        maxDate = sortedTrend.last?.date ?? Date()
    }
}

#Preview {
    WeightTrendView()
}
