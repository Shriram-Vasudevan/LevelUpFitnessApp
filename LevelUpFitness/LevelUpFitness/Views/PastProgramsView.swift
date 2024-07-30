//
//  PastProgramsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/30/24.
//

import SwiftUI

struct PastProgramsView: View {
    @ObservedObject var storageManager: StorageManager
    var body: some View {
        ZStack {
            
        }
        .onAppear {
            if storageManager.userProgramNames == nil {
                Task {
                    await storageManager.getUserProgramNames()
                }
            }
        }
    }
}

#Preview {
(    PastProgramsView(storageManager: StorageManager())
)}
