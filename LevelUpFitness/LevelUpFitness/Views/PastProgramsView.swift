//
//  PastProgramsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/30/24.
//

import SwiftUI

struct PastProgramsView: View {
    @ObservedObject var programManager: ProgramManager
    @State private var isRefreshing = false
    
    var viewPastProgram: (String) -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "F5F5F5").edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                HStack {
                    Text("Past Programs")
                        .font(.system(size: 24, weight: .bold, design: .default))
                    
                    Spacer()
                    
                    Button(action: refreshProgramNames) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(hex: "40C4FC"))
                            .rotationEffect(Angle(degrees: isRefreshing ? 360 : 0))
                            .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                    }
                }
                .padding(.horizontal)
                
                if let userProgramNames = programManager.userProgramNames {
                    if userProgramNames.isEmpty {
                        Text("No past programs found")
                            .font(.system(size: 16, weight: .light, design: .default))
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 16) {
                                ForEach(userProgramNames, id: \.self) { name in
                                    if let programFormatted = StringUtility.formatS3ProgramRepresentation(name) {
                                        PastProgramWidget(programUnformatted: name, programFormatted: programFormatted, viewPastProgram: viewPastProgram)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "40C4FC")))
                        .scaleEffect(1.5)
                        .padding()
                }
            }
            .padding(.vertical)
        }
        .onAppear(perform: refreshProgramNames)
    }
    
    
    private func refreshProgramNames() {
        isRefreshing = true
        programManager.userProgramNames = nil
        Task {
            await programManager.getUserProgramNames()
            isRefreshing = false
        }
    }
}

#Preview {
    (PastProgramsView(programManager: ProgramManager(), viewPastProgram: {_ in})
)}
