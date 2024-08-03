//
//  RequestCustomProgramWidget.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/3/24.
//

import SwiftUI

struct RequestCustomProgramWidget: View {
    var body: some View {
        VStack {
            HStack {
                Image("ManRunning")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Spacer()
                
                VStack {
                    Spacer()
                    
                    Text("Request Custom Program")
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.white)
                .shadow(radius: 3)
        )
        .frame(height: UIScreen.main.bounds.height / 4.5)
        .padding()
    }
}

#Preview {
    RequestCustomProgramWidget()
}
