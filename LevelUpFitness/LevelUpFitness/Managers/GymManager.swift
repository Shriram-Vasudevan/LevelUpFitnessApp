//
//  GymManager.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/22/24.
//

import Foundation
import Combine

@MainActor
class GymManager: ObservableObject {
    static let shared = GymManager()

    @Published var currentSession: GymSession?
    @Published var elapsedTime: String = "00:00:00"
    
    @Published var gymSessions: [GymSession] = []
    
    private var timer: AnyCancellable?
    private var startTime: Date?
    
    init() {
        self.gymSessions = loadAllGymSessions()
    }
    
    func startGymSession() {
        startTime = Date()
        currentSession = GymSession(startTime: startTime!)

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateElapsedTime()
            }
    }

    func endGymSession() {
        if var session = currentSession {
            session.endTime = Date()
            saveGymSession(session)
            currentSession = nil
        }
        
        timer?.cancel()
        timer = nil
    }
    
    private func updateElapsedTime() {
        guard let startTime = startTime else { return }
        let elapsedTimeInterval = Date().timeIntervalSince(startTime)
        
        let hours = Int(elapsedTimeInterval) / 3600
        let minutes = (Int(elapsedTimeInterval) % 3600) / 60
        let seconds = Int(elapsedTimeInterval) % 60
        
        elapsedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
     func saveGymSession(_ session: GymSession) {

        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(session)
            let url = getDocumentsDirectory().appendingPathComponent("GymSessions/\(session.id).json")
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: url)
            print("Saved session to \(url)")
        } catch {
            print("Failed to save session: \(error)")
        }
    }
    
    func loadAllGymSessions() -> [GymSession] {
        let directoryURL = getDocumentsDirectory().appendingPathComponent("GymSessions")
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
            let decoder = JSONDecoder()
            return fileURLs.compactMap { url in
                if let data = try? Data(contentsOf: url),
                   let session = try? decoder.decode(GymSession.self, from: data) {
                    return session
                }
                return nil
            }
        } catch {
            print("Error loading gym sessions: \(error)")
            return []
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

