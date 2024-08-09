//
//  PastProgramsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/30/24.
//

import SwiftUI

struct PastProgramsView: View {
    @ObservedObject var programManager: ProgramManager
    
    var body: some View {
        ZStack {
            VStack {
                if let userProgramNames = programManager.userProgramNames {
                    ForEach(userProgramNames, id: \.self) { name in
                        
                    }
                }
            }
        }
        .onAppear {
            if programManager.userProgramNames == nil {
                Task {
                    await programManager.getUserProgramNames()
                }
            }
        }
    }
}

#Preview {
(    PastProgramsView(programManager: ProgramManager())
)}
