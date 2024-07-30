//
//  TimeSpentWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/30/24.
//

import SwiftUI
import Charts

struct TimeSpentWidget: View {
    var data: [TimeData]
    
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
                    StatisticsWidget(width: geometry.size.width / 3, colorA: .blue, colorB: .cyan, stat: 45, text: "min. average")
                    
                    Chart {
                        ForEach(data, id: \.id) { data in
                            LineMark (
                                x: .value("Day", data.day),
                                y: .value("Time", data.value)
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
                .shadow(radius: 3)
        )
        .padding()
        
    }
}

#Preview {
    TimeSpentWidget(data: [
        TimeData(day: "Mon", value: 5),
        TimeData(day: "Tue", value: 10),
        TimeData(day: "Wed", value: 7),
        TimeData(day: "Thu", value: 12),
        TimeData(day: "Fri", value: 6),
        TimeData(day: "Sat", value: 15),
        TimeData(day: "Sun", value: 9)
    ])
}
