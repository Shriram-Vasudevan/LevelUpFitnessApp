import SwiftUI
import Charts

struct WeightTrendView: View {
    @ObservedObject var trendManager = TrendManager.shared
    @State private var weight: String = ""
    
    private let accentColor = Color(hex: "40C4FC")
    private let grayColor = Color(hex: "F5F5F5")
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Weight Trend")
                            .font(.system(size: 22, weight: .bold, design: .default))
                        Text("Last 30 Days")
                            .font(.system(size: 12, weight: .ultraLight, design: .default))
                            .foregroundColor(Color.gray)
                    }
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
                .padding(.top)
                .padding(.bottom, 12)
                
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let maxValue = (trendManager.weightTrend.map { $0.value }.max() ?? 0) * 1.1
                    let minValue = (trendManager.weightTrend.map { $0.value }.min() ?? 0) * 0.9
                    
                    ZStack {
                        VStack {
                            ForEach(0..<6) { index in
                                let labelValue = maxValue - CGFloat(index) * (maxValue - minValue) / 5
                                HStack {
                                    Text(String(format: "%.1f", labelValue))
                                        .font(.system(size: 10, weight: .light, design: .default))
                                        .foregroundColor(.gray)
                                        .frame(width: 40, alignment: .leading)
                                    Spacer()
                                }
                                .frame(height: height / 6)
                            }
                        }
                        
                        VStack {
                            Spacer()
                            HStack {
                                ForEach(trendManager.weightTrend.indices, id: \.self) { index in
                                    if index % 2 == 0 {
                                        let date = trendManager.weightTrend[index].date
                                        Text(date, style: .date)
                                            .font(.system(size: 10, weight: .light, design: .default))
                                            .foregroundColor(.gray)
                                            .offset(x: index == 0 ? 10 : 0)
                                    }
                                    Spacer()
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    
                        Path { path in
                            if let firstPoint = trendManager.weightTrend.first {
                                let firstX = CGFloat(0) / CGFloat(trendManager.weightTrend.count - 1) * width
                                let firstY = (1 - CGFloat((firstPoint.value - minValue) / (maxValue - minValue))) * height
                                path.move(to: CGPoint(x: firstX, y: firstY))
                                
                                for (index, point) in trendManager.weightTrend.enumerated() {
                                    let x = CGFloat(index) / CGFloat(trendManager.weightTrend.count - 1) * width
                                    let y = (1 - CGFloat((point.value - minValue) / (maxValue - minValue))) * height
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                                path.addLine(to: CGPoint(x: width, y: height))
                                path.addLine(to: CGPoint(x: 0, y: height))
                                path.closeSubpath()
                            }
                        }
                        .fill(accentColor.opacity(0.2))
                        
                        Path { path in
                            if let firstPoint = trendManager.weightTrend.first {
                                let firstX = CGFloat(0) / CGFloat(trendManager.weightTrend.count - 1) * width
                                let firstY = (1 - CGFloat((firstPoint.value - minValue) / (maxValue - minValue))) * height
                                path.move(to: CGPoint(x: firstX, y: firstY))
                                
                                for (index, point) in trendManager.weightTrend.enumerated() {
                                    let x = CGFloat(index) / CGFloat(trendManager.weightTrend.count - 1) * width
                                    let y = (1 - CGFloat((point.value - minValue) / (maxValue - minValue))) * height
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(accentColor, lineWidth: 2)
                        
                        ForEach(trendManager.weightTrend) { point in
                            let index = trendManager.weightTrend.firstIndex(where: { $0.id == point.id })!
                            let x = CGFloat(index) / CGFloat(trendManager.weightTrend.count - 1) * width
                            let y = (1 - CGFloat((point.value - minValue) / (maxValue - minValue))) * height
                            
                            Circle()
                                .fill(accentColor)
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.vertical, 16)
                
                HStack(spacing: 16) {
                    TextField("Enter weight", text: $weight)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .padding()
                        .background(grayColor)
                        .frame(maxWidth: .infinity)
                    
                    Button(action: addWeight) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(accentColor)
                    }
                }
                .padding(.top)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Latest Entries")
                        .font(.system(size: 18, weight: .medium, design: .default))
                    
                    ScrollView (.vertical) {
                        ForEach(trendManager.weightTrend.prefix(10)) { entry in
                            HStack {
                                Text(entry.date, style: .date)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.black)
                                Spacer()
                                Text(String(format: "%.1f lbs", entry.value))
                                    .font(.system(size: 14, weight: .medium, design: .default))
                                    .foregroundColor(accentColor)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(grayColor)
                        }
                    }
                }
                .padding(.top)
            }
            .padding(.horizontal)
        
        }
        .onAppear {
            Task {
                if trendManager.weightTrend.count == 0 {
                    await trendManager.getWeightTrend()
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func addWeight() {
        guard let weightValue = Double(weight) else { return }
        Task {
            await trendManager.addWeightToTrend(weight: weightValue)
            weight = ""
            ToDoListManager.shared.weightAdded()
        }
    }
}

#Preview {
    WeightTrendView()
}
