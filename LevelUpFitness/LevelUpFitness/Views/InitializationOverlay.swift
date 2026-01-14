//
//  InitializationOverlay.swift
//  LevelUpFitness
//
//  Created for app initialization error handling
//

import SwiftUI

struct InitializationOverlay: View {
    let error: String?
    let onRetry: () -> Void

    var body: some View {
        if let error = error {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)

                    Text("Initialization Error")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Button(action: onRetry) {
                        Text("Retry")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(height: 44)
                            .frame(maxWidth: 200)
                            .background(Color(hex: "40C4FC"))
                            .cornerRadius(10)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(radius: 20)
                )
                .padding(.horizontal, 40)
            }
        }
    }
}
