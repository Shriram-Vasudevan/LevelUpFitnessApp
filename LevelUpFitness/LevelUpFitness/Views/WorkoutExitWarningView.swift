//
//  WorkoutExitWarningView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/3/24.
//

import SwiftUI

struct WorkoutExitWarningView: View {
    @Binding var isOpen: Bool
    @State var offset: CGFloat = 1000
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            VStack {
                Text("Warning, this will exit your workout without saving your progress")
                    .bold()
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(.white)
                
            )
            .offset(x: 0, y: offset)
        }
        .onAppear {
            offset = 0
        }
    }
    
    func close() {
        withAnimation(.spring(duration: 1)) {
            offset = 1000
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isOpen = false
        }
    }
}

#Preview {
    WorkoutExitWarningView(isOpen: .constant(true))
}
