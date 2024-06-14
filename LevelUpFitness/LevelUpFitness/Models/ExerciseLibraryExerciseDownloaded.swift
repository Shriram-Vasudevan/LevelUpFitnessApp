//
//  ExerciseLibraryExerciseDownloaded.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/14/24.
//

import Foundation

struct ExerciseLibraryExerciseDownloaded: Codable, Identifiable {
    var id = UUID()
    var name: String
    var videoURL: URL
}
