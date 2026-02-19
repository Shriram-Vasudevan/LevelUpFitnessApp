//
//  PastProgramsView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 7/30/24.
//

import SwiftUI

struct PastProgramsView: View {
    @ObservedObject var programManager: ProgramManager
    @State private var isRefreshing = false

    var viewPastProgram: (String) -> Void

    var body: some View {
        ZStack {
            Color(hex: "F3F5F8").ignoresSafeArea()

            VStack(spacing: 0) {
                navigationBar

                ScrollView {
                    VStack(spacing: 10) {
                        if isRefreshing && programManager.userActivePrograms.isEmpty {
                            loadingView
                        } else if programManager.userActivePrograms.isEmpty {
                            emptyStateView
                        } else {
                            programList(programManager.userActivePrograms.map(\.program))
                        }
                    }
                    .padding(16)
                }
            }
        }
        .task {
            refreshProgramNames()
        }
    }

    private var navigationBar: some View {
        HStack {
            Text("Program History")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            Spacer()

            Button(action: refreshProgramNames) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(hex: "0B5ED7"))
                    .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                    .animation(
                        isRefreshing
                        ? .linear(duration: 0.9).repeatForever(autoreverses: false)
                        : .default,
                        value: isRefreshing
                    )
                    .frame(width: 34, height: 34)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "F3F5F8"))
    }

    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No past programs found")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))
            Text("Program history entries will appear after your first completed cycle.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func programList(_ userProgramNames: [String]) -> some View {
        VStack(spacing: 8) {
            ForEach(userProgramNames, id: \.self) { name in
                if let formatted = StringUtility.formatS3ProgramRepresentation(name) {
                    PastProgramWidget(
                        programUnformatted: name,
                        programFormatted: formatted,
                        viewPastProgram: viewPastProgram
                    )
                }
            }
        }
    }

    private var loadingView: some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "0B5ED7")))
            Text("Refreshing program history...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func refreshProgramNames() {
        isRefreshing = true
        Task {
            let activePrograms = await programManager.loadUserActivePrograms()
            await MainActor.run {
                programManager.userActivePrograms = activePrograms
                isRefreshing = false
            }
        }
    }
}

#Preview {
    PastProgramsView(programManager: ProgramManager(), viewPastProgram: { _ in })
}
