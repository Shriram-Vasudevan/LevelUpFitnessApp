//
//  IntroView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 9/28/24.
//

import SwiftUI

struct IntroView: View {
    @State private var currentStep: Int = 0
    private let totalSteps = 6
    var onIntroCompletion: () -> Void // Completion handler for finishing the intro
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // Background color
            
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
                    
//                    Button(action: {
//                        onIntroCompletion()
//                    }) {
//                        Text("Skip")
//                            .foregroundColor(Color(hex: "40C4FC"))
//                            .font(.system(size: 16, weight: .medium))
//                    }
                }
                
                VStack(spacing: 16) {
                    Text(getTitle(for: currentStep))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text(getDescription(for: currentStep))
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 7)
                
                Image("feature\(currentStep + 1)")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 450)
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
                                onIntroCompletion()
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

    func getTitle(for step: Int) -> String {
        switch step {
        case 0: return "Welcome to LevelUp Fitness"
        case 1: return "Track Your Progress"
        case 2: return "Complete your Program"
        case 3: return "Unleash your Creativity"
        case 4: return "Enhance the Gym"
        case 5: return "Join Challenges"
        default: return ""
        }
    }
    
    func getDescription(for step: Int) -> String {
        switch step {
        case 0: return "We're excited to help you reach your fitness goals."
        case 1: return "Use Levels to monitor your improvement"
        case 2: return "Join one of our expertly-crafted programs"
        case 3: return "Build your own workouts"
        case 4: return "Level Up is your new gym buddy"
        case 5: return "Join fitness challenges and complete them"
        default: return ""
        }
    }
}

#Preview {
    IntroView(onIntroCompletion: {})
}
