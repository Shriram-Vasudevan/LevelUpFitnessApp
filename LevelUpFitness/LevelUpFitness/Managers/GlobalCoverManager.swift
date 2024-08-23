//
//  GlobalCoverManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/21/24.
//

import Foundation

class GlobalCoverManager: ObservableObject {
    static let shared = GlobalCoverManager()
    
    @Published var showProgramCompletionCover = false
    @Published var showProgramDayCompletionCover = false
    @Published var showChallengeCompletionCover = false
    
    func showChallengeCompletion() {
        self.showChallengeCompletionCover = true
    }
    
    func showProgramCompletion() {
        self.showProgramCompletionCover = true
    }
    
    func showProgramDayCompletion() {
        self.showProgramDayCompletionCover = true
    }
}

