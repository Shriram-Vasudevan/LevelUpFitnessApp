//
//  PastProgramsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/30/24.
//

import SwiftUI

struct PastProgramsView: View {
    @ObservedObject var programManager: ProgramManager
    
    var viewPastProgram: (String) -> Void
    var body: some View {
        ZStack {
            VStack {
                if let userProgramNames = programManager.userProgramNames {
                    ForEach(userProgramNames, id: \.self) { name in
                        if let programFormatted = StringUtility.formatS3ProgramRepresentation(name) {
                            
                            PastProgramWidget(programUnformatted: name, programFormatted: programFormatted, viewPastProgram: { programUnformatted in
                                viewPastProgram(programUnformatted)
                            })
                        }
                        
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
    (PastProgramsView(programManager: ProgramManager(), viewPastProgram: {_ in})
)}
