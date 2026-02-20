//
//  IndividualExerciseView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/8/24.
//

import SwiftUI
import AVKit

struct IndividualExerciseView: View {
    var progression: Progression

    @Environment(\.dismiss) private var dismiss
    @State private var avPlayer = AVPlayer()
    @State private var videoURL: URL?

    var body: some View {
        ZStack {
            Color(hex: "F3F5F8").ignoresSafeArea()

            ScrollView(.vertical) {
                VStack(spacing: 14) {
                    header
                    videoCard
                    detailsCard
                    LibraryExerciseDataView(
                        progression: progression,
                        exerciseData: ExerciseData(sets: []),
                        isWeight: progression.isWeight,
                        exerciseType: progression.exerciseType
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            guard let cdnURL = URL(string: progression.cdnURL) else { return }
            LocalStorageUtility.downloadVideoAndSaveToTempFile(url: cdnURL) { result in
                switch result {
                case .success(let localURL):
                    videoURL = localURL
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Exercise")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            Spacer()

            Color.clear
                .frame(width: 32, height: 32)
        }
    }

    private var videoCard: some View {
        ZStack {
            if let videoURL {
                VideoPlayer(player: avPlayer)
                    .onAppear {
                        avPlayer = AVPlayer(url: videoURL)
                        avPlayer.play()
                    }
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(Color(hex: "0B5ED7"))
                    Text("Loading video")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "F8FAFC"))
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(progression.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            HStack(spacing: 8) {
                detailPill(label: progression.exerciseType)
                detailPill(label: progression.isWeight ? "Strength" : "Bodyweight")
                detailPill(label: "Level \(progression.level)")
            }

            Text(progression.description)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "4B5563"))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func detailPill(label: String) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: "0B5ED7"))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(Color(hex: "E8F3FF"))
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

#Preview {
    IndividualExerciseView(progression: Progression.preview()!)
}
