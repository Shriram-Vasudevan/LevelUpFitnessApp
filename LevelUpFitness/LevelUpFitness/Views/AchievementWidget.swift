//
//  AchievementWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/3/24.
//

import SwiftUI

struct AchievementWidget: View {
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Image("AchievementBadge")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                
                VStack (alignment: .leading){
                    Text("Fitness Frenzy")
                        .bold()
                    
                    Text("Completed 5 workout sessions! Your dedication is inspiring!")
                }

            }
        
            HStack (spacing: 15){
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: UIScreen.main.bounds.width * 0.4, height: 20)
                }
                
                Spacer()
                
                Text("60%")
                    .bold()
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(.white)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}

#Preview {
    AchievementWidget()
}
