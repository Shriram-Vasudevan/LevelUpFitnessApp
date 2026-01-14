//
//  StoreKitManager.swift
//  LevelUpFitness
//
//  Created by OpenAI Assistant on 10/7/24.
//

import Foundation
import StoreKit
import UIKit

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
    @Published private(set) var productLoadError: String?
    @Published private(set) var connectionState: ConnectionState = .connected

    enum ConnectionState {
        case connected
        case disconnected
        case retrying
    }

    private let premiumStatusKey = "com.levelupfitness.premiumUnlockedCache"

    #if DEBUG
    @Published var debugMode: Bool = false
    @Published var debugPremiumOverride: Bool = false

    var effectiveIsPremiumUnlocked: Bool {
        debugMode ? debugPremiumOverride : isPremiumUnlocked
    }

    func resetSubscriptionStateForTesting() {
        isPremiumUnlocked = false
        activeSubscription = nil
        availableProducts = []
        lastError = nil
        productLoadError = nil
    }
    #else
    var effectiveIsPremiumUnlocked: Bool {
        isPremiumUnlocked
    }
    #endif

    private init() {
        restoreFromCacheIfNeeded()
        Task {
            await listenForTransactions()
        }
    }

    private func cacheSubscriptionStatus() {
        UserDefaults.standard.set(isPremiumUnlocked, forKey: premiumStatusKey)
    }

    private func restoreFromCacheIfNeeded() {
        if availableProducts.isEmpty {
            let cached = UserDefaults.standard.bool(forKey: premiumStatusKey)
            if cached != isPremiumUnlocked {
                isPremiumUnlocked = cached
            }
        }
    }

    func refresh() async {
        await updateProducts()
        await updateSubscriptionStatus()
    }

    func recordPaywallTrigger(_ reason: PaywallTriggerReason) {
        lastPaywallTrigger = reason
    }

    func updateProducts(retryCount: Int = 3) async {
        guard !isLoadingProducts else { return }
        isLoadingProducts = true
        productLoadError = nil
        defer { isLoadingProducts = false }

        var attempts = 0
        while attempts < retryCount {
            do {
                let productIDs = SubscriptionTier.allCases.map(\.rawValue)
                let storeProducts = try await Product.products(for: productIDs)

                if storeProducts.isEmpty {
                    productLoadError = "Products not configured in App Store Connect"
                    connectionState = .disconnected
                } else {
                    availableProducts = storeProducts.sorted(by: { lhs, rhs in
                        lhs.price < rhs.price
                    })
                    connectionState = .connected
                    productLoadError = nil
                    return
                }
            } catch {
                attempts += 1
                if attempts < retryCount {
                    connectionState = .retrying
                    try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
                } else {
                    productLoadError = "Unable to load subscription options. Please check your internet connection."
                    connectionState = .disconnected
                    lastError = error.localizedDescription
                    print("StoreKitManager updateProducts error: \(error.localizedDescription)")
                }
            }
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

        // Cache the subscription status for offline use
        cacheSubscriptionStatus()
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
        if #available(iOS 15.0, *) {
            do {
                if let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                }
            } catch {
                lastError = error.localizedDescription
                print("StoreKitManager manage subscriptions error: \(error.localizedDescription)")
            }
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
