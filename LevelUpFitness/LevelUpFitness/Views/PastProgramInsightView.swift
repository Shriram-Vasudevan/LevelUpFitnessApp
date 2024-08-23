//
//  PastProgramInsightView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/23/24.
//

import SwiftUI

struct PastProgramInsightView: View {
    var programS3Representation: String
    
    var body: some View {
        ZStack {
            VStack {
                
            }
        }
        .onAppear {
            Task {
                if let paths = await S3Utility.getUserProgramFilePaths(programS3Representation: programS3Representation) {
                    
                }
            }
        }
    }
}

#Preview {
    PastProgramInsightView(programS3Representation: "Muscle Maximization")
}
