//
//  StoreKitManager.swift
//  LevelUpFitness
//
//  Created by OpenAI Assistant on 10/7/24.
//

import Foundation
import StoreKit

@MainActor
final class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    enum SubscriptionTier: String, CaseIterable, Identifiable {
        case monthly = "com.levelupfitness.premium.monthly"
        case annual = "com.levelupfitness.premium.annual"

        var id: String { rawValue }

        var marketingName: String {
            switch self {
            case .monthly:
                return "LevelUp Premium Monthly"
            case .annual:
                return "LevelUp Premium Annual"
            }
        }

        var marketingBlurb: String {
            switch self {
            case .monthly:
                return "Full access, billed every month"
            case .annual:
                return "Best value — 12 months for the price of 10"
            }
        }
    }

    enum PaywallTriggerReason: Equatable {
        case onboarding
        case premiumProgram(name: String)
        case premiumAnalytics
        case premiumHistory
        case manualUpgrade

        var title: String {
            switch self {
            case .onboarding:
                return "Unlock your personalized training"
            case let .premiumProgram(name):
                return "\(name) is a Premium program"
            case .premiumAnalytics:
                return "Unlock advanced training analytics"
            case .premiumHistory:
                return "See every session you've logged"
            case .manualUpgrade:
                return "Upgrade to LevelUp Premium"
            }
        }

        var subtitle: String {
            switch self {
            case .onboarding:
                return "Try Premium to unlock expert programs, unlimited history, and deeper insights."
            case .premiumProgram:
                return "Subscribe to Premium to join elite programs crafted by our coaches."
            case .premiumAnalytics:
                return "Premium charts transform your logs into actionable trends."
            case .premiumHistory:
                return "Premium members keep every workout at their fingertips."
            case .manualUpgrade:
                return "Enjoy the full LevelUp experience with powerful extras."
            }
        }
    }

    @Published private(set) var availableProducts: [Product] = []
    @Published private(set) var isPremiumUnlocked: Bool = false
    @Published private(set) var activeSubscription: Product?
    @Published private(set) var isLoadingProducts: Bool = false
    @Published private(set) var purchaseInProgress: Bool = false
    @Published var lastPaywallTrigger: PaywallTriggerReason?
    @Published var lastError: String?

    private init() {
        Task {
            await listenForTransactions()
        }
    }

    func refresh() async {
        await updateProducts()
        await updateSubscriptionStatus()
    }

    func recordPaywallTrigger(_ reason: PaywallTriggerReason) {
        lastPaywallTrigger = reason
    }

    func updateProducts() async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let productIDs = SubscriptionTier.allCases.map(\.rawValue)
            let storeProducts = try await Product.products(for: productIDs)
            availableProducts = storeProducts.sorted(by: { lhs, rhs in
                lhs.price < rhs.price
            })
        } catch {
            lastError = error.localizedDescription
            print("StoreKitManager updateProducts error: \(error.localizedDescription)")
        }
    }

    func updateSubscriptionStatus() async {
        var latestEntitlement: Product?
        var lastSeenError: String?

        for await verificationResult in Transaction.currentEntitlements {
            switch verificationResult {
            case .verified(let transaction):
                guard SubscriptionTier.allCases.contains(where: { $0.rawValue == transaction.productID }) else { continue }
                if let product = availableProducts.first(where: { $0.id == transaction.productID }) {
                    latestEntitlement = product
                } else if let fetchedProduct = try? await Product.products(for: [transaction.productID]).first {
                    latestEntitlement = fetchedProduct
                }
            case .unverified(let transaction, let error):
                if SubscriptionTier.allCases.contains(where: { $0.rawValue == transaction.productID }) {
                    lastSeenError = error.localizedDescription
                }
            }
        }

        isPremiumUnlocked = latestEntitlement != nil
        activeSubscription = latestEntitlement
        lastError = lastSeenError
    }

    func purchase(_ product: Product) async {
        guard !purchaseInProgress else { return }
        purchaseInProgress = true
        defer { purchaseInProgress = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verificationResult):
                switch verificationResult {
                case .verified(let transaction):
                    await transaction.finish()
                    await updateSubscriptionStatus()
                case .unverified:
                    lastError = "Unable to verify the transaction."
                }
            case .pending:
                lastError = "Purchase pending approval."
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            lastError = error.localizedDescription
            print("StoreKitManager purchase error: \(error.localizedDescription)")
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
        } catch {
            lastError = error.localizedDescription
            print("StoreKitManager restore error: \(error.localizedDescription)")
        }
    }

    func showManageSubscriptions() async {
        do {
            try await AppStore.showManageSubscriptions()
        } catch {
            lastError = error.localizedDescription
            print("StoreKitManager manage subscriptions error: \(error.localizedDescription)")
        }
    }

    private func listenForTransactions() async {
        for await update in Transaction.updates {
            switch update {
            case .verified(let transaction):
                await transaction.finish()
                await updateSubscriptionStatus()
            case .unverified:
                continue
            }
        }
    }
}
