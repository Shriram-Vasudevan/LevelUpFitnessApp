//
//  IntroView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/28/24.
//

import SwiftUI

struct IntroView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @State private var currentStep: Int = 0
    @State private var showPrivacyPolicy: Bool = false
    @State private var showPaywall: Bool = false
    private let totalSteps = 7
    var onIntroCompletion: () -> Void
    
    var body: some View {
        ZStack {
            if showPrivacyPolicy {
                VStack {
                    VStack (spacing: 5) {
                        Text("Privacy Policy")
                            .font(.system(size: 24, weight: .bold))
                            .padding()
                        
                        if let url = URL(string: "https://www.banw.net/privacy/levelupfitnessprivacy") {
                            WebView(url: url)
                        }
                    }
                    
                    Button(action: {
                        Task {
                            await LevelChangeManager.shared.createNewLevelChange(property: "JoinedLevelUp", contribution: 10)
                        }
                        if storeKitManager.effectiveIsPremiumUnlocked {
                            onIntroCompletion()
                        } else {
                            storeKitManager.recordPaywallTrigger(.onboarding)
                            showPaywall = true
                        }
                    }) {
                        Text("Accept")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color(hex: "40C4FC"))
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .background(Color.white.ignoresSafeArea())
            } else {
                Color.white.ignoresSafeArea()
                
                VStack {
                    HStack {
                        if currentStep > 0 {
                            Button(action: {
                                withAnimation {
                                    if currentStep > 0 {
                                        currentStep -= 1
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .foregroundColor(Color(hex: "40C4FC"))
                            }
                        }
                        
                        Spacer()
                        
//                        Button(action: {
//                            onIntroCompletion()
//                        }) {
//                            Text("Skip")
//                                .foregroundColor(Color(hex: "40C4FC"))
//                                .font(.system(size: 16, weight: .medium))
//                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text(getTitle(for: currentStep))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(getDescription(for: currentStep))
                            .font(.system(size: 16, weight: .light))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Image("feature\(currentStep + 1)")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: 550)
                        .padding(.horizontal, 16)
                    
                    Spacer()

                    VStack (spacing: 0) {
                        HStack(spacing: 8) {
                            ForEach(0..<totalSteps) { index in
                                Circle()
                                    .fill(currentStep == index ? Color(hex: "40C4FC") : Color.gray.opacity(0.5))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        Button(action: {
                            withAnimation {
                                if currentStep < totalSteps - 1 {
                                    currentStep += 1
                                } else {
                                    showPrivacyPolicy = true
                                }
                            }
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(Color(hex: "40C4FC"))
                                .clipShape(Circle())
                                .padding()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            PaywallView(allowDismissal: true) {
                onIntroCompletion()
            }
            .environmentObject(storeKitManager)
        }
    }

    func getTitle(for step: Int) -> String {
        switch step {
        case 0: return "Welcome to LevelUp Fitness"
        case 1: return "Track your Progress"
        case 2: return "Select a Program"
        case 3: return "Complete Programs"
        case 4: return "Enhance the Gym"
        case 5: return "Unleash your Creativity"
        case 6: return "We use iCloud"
        default: return ""
        }
    }
    
    func getDescription(for step: Int) -> String {
        switch step {
        case 0: return "We're excited to help you reach your fitness goals"
        case 1: return "Use Levels to monitor your improvement"
        case 2: return "Join one of our expertly-crafted programs"
        case 3: return "Work hard and see results!"
        case 4: return "Level Up is your new gym buddy"
        case 5: return "Create your own custom workouts"
        case 6: return "No emails or passwords to remember, everything is connected to your iCloud account"
        default: return ""
        }
    }
}

#Preview {
    IntroView(onIntroCompletion: {})
        .environmentObject(StoreKitManager.shared)
}
