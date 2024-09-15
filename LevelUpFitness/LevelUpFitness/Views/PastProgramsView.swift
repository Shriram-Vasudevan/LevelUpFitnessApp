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
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                navigationBar
                
                ScrollView {
                    VStack(spacing: 16) {
                        if let userProgramNames = programManager.userProgramNames {
                            if userProgramNames.isEmpty {
                                emptyStateView
                            } else {
                                programList(userProgramNames)
                            }
                        } else {
                            loadingView
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear(perform: refreshProgramNames)
    }
    
    private var navigationBar: some View {
        ZStack {
            Text("Past Programs")
                .font(.system(size: 18, weight: .semibold))
            
            HStack {
                Spacer()
                Button(action: refreshProgramNames) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "40C4FC"))
                        .rotationEffect(Angle(degrees: isRefreshing ? 360 : 0))
                        .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var emptyStateView: some View {
        Text("No past programs found")
            .font(.system(size: 16, weight: .light))
            .foregroundColor(.gray)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "F5F5F5"))
    }
    
    private func programList(_ userProgramNames: [String]) -> some View {
        VStack(spacing: 1) {
            ForEach(userProgramNames, id: \.self) { name in
                if let programFormatted = StringUtility.formatS3ProgramRepresentation(name) {
                    PastProgramWidget(programUnformatted: name, programFormatted: programFormatted, viewPastProgram: viewPastProgram)
                }
            }
        }
        .background(Color(hex: "F5F5F5"))
    }
    
    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "40C4FC")))
            .scaleEffect(1.5)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(hex: "F5F5F5"))
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
