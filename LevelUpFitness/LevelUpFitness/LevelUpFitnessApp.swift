//
//  LevelUpFitnessApp.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/7/24.
//

import SwiftUI
import StoreKit

@main
struct LevelUpFitnessApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var storeKitManager = StoreKitManager.shared

    var body: some Scene {
        WindowGroup {
            OpeningViewsContainer()
                .environmentObject(storeKitManager)
                .task {
                    await storeKitManager.refresh()
                }
        }
    }
}

struct OpeningViewsContainer: View {
    @State private var showSplashScreen = true
    @State private var showIntroView = FirstLaunchManager.shared.isFirstLaunch
    @State private var isInitializing = true
    @State private var initializationError: String?
    @EnvironmentObject private var storeKitManager: StoreKitManager

    var body: some View {
        ZStack {
            if showSplashScreen {
                SplashScreenView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showSplashScreen = false
                            }
                        }
                    }
                    .preferredColorScheme(.light)
            } else if showIntroView {
                IntroView(onIntroCompletion: {
                    withAnimation {
                        FirstLaunchManager.shared.markAsLaunched()
                        showIntroView = false
                    }
                })
                .preferredColorScheme(.light)
            } else {
                PagesHolderView(pageType: .home)
                    .transition(.opacity)
                    .preferredColorScheme(.light)
            }

            // Show initialization overlay if there's an error and we're not showing splash or intro
            if isInitializing && !showSplashScreen && !showIntroView {
                InitializationOverlay(
                    error: initializationError,
                    onRetry: {
                        Task {
                            initializationError = nil
                            isInitializing = true
                            await initializeApp()
                        }
                    }
                )
            }
        }
        .animation(.easeInOut, value: showSplashScreen || showIntroView)
        .task {
            await initializeApp()
        }
        .navigationBarBackButtonHidden()
    }

    private func initializeApp() async {
        await InitializationManager.shared.initialize()
        await storeKitManager.refresh()

        // Check if products loaded successfully
        if storeKitManager.availableProducts.isEmpty && storeKitManager.productLoadError != nil {
            initializationError = storeKitManager.productLoadError
        }

        isInitializing = false
    }

}

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

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        #if targetEnvironment(simulator)
            if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
                print("Documents Directory: \(documentsPath)")
            }
        #endif

        NotificationManager.shared.askPermission()
        return true
    }
}
