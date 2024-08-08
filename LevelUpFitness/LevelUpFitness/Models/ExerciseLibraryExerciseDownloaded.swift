//
//  ExerciseLibraryExerciseDownloaded.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/14/24.
//

import Foundation

struct ExerciseLibraryExerciseDownloaded: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var videoURL: URL
    var description: String
    var bodyArea: String
    var level: Int
}
