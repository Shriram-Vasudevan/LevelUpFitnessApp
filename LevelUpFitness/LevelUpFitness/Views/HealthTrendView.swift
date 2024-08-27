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
    
    var healthStatType: String
    
    var body: some View {
        VStack {
            Text("Steps Over the Last 7 Days")
                .font(.headline)
                .padding()
            
            Chart(healthData) {
                LineMark(
                    x: .value("Date", $0.date, unit: .day),
                    y: .value("Steps", $0.value)
                )
            }
            .chartYScale(domain: 0...maxValue)
            .padding()
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
                
                maxValue = data.map { $0.value }.max() ?? 2000
                            
                maxValue += maxValue * 0.1
            }
        }
    }
}

#Preview {
    HealthTrendView(healthStatType: "Steps")
}
