//
//  HealthTrendView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/26/24.
//

import SwiftUI
import Charts
import HealthKit

struct HealthTrendView: View {
    @ObservedObject var healthManager = HealthManager.shared
    @State private var healthData: [HealthDataPoint] = []
    @State private var maxValue: Double = 0
    @State private var healthValue: String = ""
    
    private let accentColor = Color(hex: "40C4FC")
    private let grayColor = Color(hex: "F5F5F5")
    
    @Environment(\.dismiss) var dismiss
    
    var healthStatType: String
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(healthStatType) Trend")
                            .font(.system(size: 22, weight: .bold, design: .default))
                        Text("Last 7 Days")
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
                    let maxValueAdjusted = maxValue * 1.1
                    let minValueAdjusted = 0.0
                    
                    ZStack {
                        VStack {
                            ForEach(0..<6) { index in
                                let labelValue = maxValueAdjusted - CGFloat(index) * (maxValueAdjusted - minValueAdjusted) / 5
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
                                ForEach(0..<healthData.count, id: \.self) { index in
                                    if index % 2 == 0 {
                                        let date = healthData[index].date
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
                            if let firstPoint = healthData.first {
                                let firstX = CGFloat(0) / CGFloat(healthData.count - 1) * width
                                let firstY = (1 - CGFloat((firstPoint.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
                                path.move(to: CGPoint(x: firstX, y: firstY))
                                
                                for (index, point) in healthData.enumerated() {
                                    let x = CGFloat(index) / CGFloat(healthData.count - 1) * width
                                    let y = (1 - CGFloat((point.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                                path.addLine(to: CGPoint(x: width, y: height))
                                path.addLine(to: CGPoint(x: 0, y: height))
                                path.closeSubpath()
                            }
                        }
                        .fill(accentColor.opacity(0.2))
                        
                        Path { path in
                            if let firstPoint = healthData.first {
                                let firstX = CGFloat(0) / CGFloat(healthData.count - 1) * width
                                let firstY = (1 - CGFloat((firstPoint.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
                                path.move(to: CGPoint(x: firstX, y: firstY))
                                
                                for (index, point) in healthData.enumerated() {
                                    let x = CGFloat(index) / CGFloat(healthData.count - 1) * width
                                    let y = (1 - CGFloat((point.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(accentColor, lineWidth: 2)
                        
                        ForEach(healthData) { point in
                            let index = healthData.firstIndex(where: { $0.id == point.id })!
                            let x = CGFloat(index) / CGFloat(healthData.count - 1) * width
                            let y = (1 - CGFloat((point.value - minValueAdjusted) / (maxValueAdjusted - minValueAdjusted))) * height
                            
                            Circle()
                                .fill(accentColor)
                                .frame(width: 8, height: 8)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.vertical, 16)

//                HStack(spacing: 16) {
//                    TextField("Enter \(healthStatType.lowercased())", text: $healthValue)
//                        .keyboardType(.decimalPad)
//                        .font(.system(size: 16, weight: .regular, design: .default))
//                        .padding()
//                        .background(grayColor)
//                        .frame(maxWidth: .infinity)
//                        .opacity(0.7)
//                        .disabled(true)
//                    
//                    Button(action: addHealthValue) {
//                        Image(systemName: "plus.circle.fill")
//                            .resizable()
//                            .frame(width: 30, height: 30)
//                            .foregroundColor(accentColor)
//                            .opacity(0.7)
//                            .disabled(true)
//                    }
//                }
//                .padding(.top)

                VStack(alignment: .leading, spacing: 16) {
                    Text("Latest Entries")
                        .font(.system(size: 18, weight: .medium, design: .default))
                    
                    ScrollView(.vertical) {
                        ForEach(healthData.prefix(5).reversed()) { entry in
                            HStack {
                                Text(entry.date, style: .date)
                                    .font(.system(size: 14, weight: .regular, design: .default))
                                    .foregroundColor(.black)
                                Spacer()
                                Text(String(format: "%.1f", entry.value))
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
            var quantityType: HKQuantityTypeIdentifier = .stepCount
            
            switch healthStatType {
                case "Steps":
                    quantityType = .stepCount
                case "Calories":
                    quantityType = .activeEnergyBurned
                case "Distance":
                    quantityType = .distanceWalkingRunning
                default:
                    break
            }
            
            healthManager.fetchHistoricalData(forLastNDays: 7, quantityType: quantityType) { data in
                healthData = data
                maxValue = data.map { $0.value }.max() ?? 0
                maxValue += maxValue * 0.1
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    private func addHealthValue() {
        guard let healthValueDouble = Double(healthValue) else { return }
        healthValue = ""
    }
}

#Preview {
    HealthTrendView(healthStatType: "Steps")
}
