//
//  WeightTrendView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/26/24.
//

import SwiftUI
import Charts

struct WeightTrendView: View {
    @State var weight: String = ""
    
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
                                await TrendManager.shared.addWeightToTrend(weight: weight)
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
                
                if let weightTrend = TrendManager.shared.weightTrend {
                    Chart(weightTrend) {
                        LineMark(
                            x: .value("Date", $0.date, unit: .day),
                            y: .value("Steps", $0.value)
                        )
                    }
                    .chartYScale(domain: 0...300)
                    .padding()
                }
                Spacer()
            }
        }
        .onAppear {
            Task {
                await TrendManager.shared.getWeightTrend()
            }
        }
    }
}

#Preview {
    WeightTrendView()
}
