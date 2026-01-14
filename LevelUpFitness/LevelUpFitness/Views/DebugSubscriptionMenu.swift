//
//  DebugSubscriptionMenu.swift
//  LevelUpFitness
//
//  Created for debugging subscription functionality
//

import SwiftUI

#if DEBUG
struct DebugSubscriptionMenu: View {
    @ObservedObject var storeKitManager: StoreKitManager

    var body: some View {
        Form {
            Section("Debug Controls") {
                Toggle("Debug Mode", isOn: $storeKitManager.debugMode)
                    .tint(Color(hex: "40C4FC"))

                if storeKitManager.debugMode {
                    Toggle("Override Premium Status", isOn: $storeKitManager.debugPremiumOverride)
                        .tint(Color(hex: "40C4FC"))

                    Button("Reset Subscription State") {
                        storeKitManager.resetSubscriptionStateForTesting()
                    }
                    .foregroundColor(.red)
                }
            }

            Section("Current State") {
                LabeledContent("Products Loaded", value: "\(storeKitManager.availableProducts.count)")
                LabeledContent("Premium Status", value: storeKitManager.effectiveIsPremiumUnlocked ? "Active" : "Inactive")

                if let subscription = storeKitManager.activeSubscription {
                    LabeledContent("Active Subscription", value: subscription.displayName)
                    LabeledContent("Price", value: subscription.displayPrice)
                }

                if let error = storeKitManager.lastError {
                    LabeledContent("Last Error") {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.trailing)
                    }
                }

                if let productError = storeKitManager.productLoadError {
                    LabeledContent("Product Load Error") {
                        Text(productError)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.trailing)
                    }
                }

                LabeledContent("Connection State") {
                    switch storeKitManager.connectionState {
                    case .connected:
                        Text("Connected")
                            .foregroundColor(.green)
                    case .disconnected:
                        Text("Disconnected")
                            .foregroundColor(.red)
                    case .retrying:
                        Text("Retrying...")
                            .foregroundColor(.orange)
                    }
                }
            }

            Section("Actions") {
                Button("Refresh Products") {
                    Task {
                        await storeKitManager.updateProducts()
                    }
                }

                Button("Refresh Subscription Status") {
                    Task {
                        await storeKitManager.updateSubscriptionStatus()
                    }
                }

                Button("Restore Purchases") {
                    Task {
                        await storeKitManager.restorePurchases()
                    }
                }
            }
        }
        .navigationTitle("Subscription Debug")
    }
}
#endif
