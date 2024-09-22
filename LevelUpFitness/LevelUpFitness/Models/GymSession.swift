//
//  GymSession.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/22/24.
//

import Foundation

struct GymSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?

    var programExercises: [String: [ExerciseRecord]]

    var individualExercises: [ExerciseRecord]

    var duration: TimeInterval? {
        guard let endTime = endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    init(startTime: Date) {
        self.id = UUID()
        self.startTime = startTime
        self.programExercises = [:]
        self.individualExercises = []
    }

    mutating func addProgramExercise(programName: String, exerciseRecord: ExerciseRecord) {
        if programExercises[programName] != nil {
            programExercises[programName]?.append(exerciseRecord)
        } else {
            programExercises[programName] = [exerciseRecord]
        }
    }

    mutating func addIndividualExercise(exerciseRecord: ExerciseRecord) {
        individualExercises.append(exerciseRecord)
    }
}

struct ExerciseRecord: Codable, Identifiable {
    let id: UUID
    let exerciseInfo: CodableExercise
    var exerciseData: ExerciseData
    
    init(exerciseInfo: CodableExercise, exerciseData: ExerciseData) {
        self.id = UUID()
        self.exerciseInfo = exerciseInfo
        self.exerciseData = exerciseData
    }
}

enum CodableExercise: Codable {
    case programExercise(ProgramExercise)
    case libraryExercise(Progression)
}
