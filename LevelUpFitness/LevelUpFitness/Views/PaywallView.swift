//
//  PaywallView.swift
//  LevelUpFitness
//
//  Created by OpenAI Assistant on 10/7/24.
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    var allowDismissal: Bool
    var onCompletion: (() -> Void)?

    @State private var selectedProductID: String?
    @State private var showError: Bool = false

    private var features: [PaywallFeature] {
        [
            PaywallFeature(icon: "figure.cross.training", title: "Elite training programs", detail: "Unlock every premium plan crafted by our coaches."),
            PaywallFeature(icon: "chart.bar.fill", title: "Advanced analytics", detail: "See volume, rest, and trend charts for every session."),
            PaywallFeature(icon: "clock.arrow.circlepath", title: "Unlimited history", detail: "Revisit every logged workout without limits."),
            PaywallFeature(icon: "wand.and.stars", title: "Upcoming drops", detail: "Be the first to access new challenges and dashboards.")
        ]
    }

    private var reason: StoreKitManager.PaywallTriggerReason? {
        storeKitManager.lastPaywallTrigger
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(hex: "0E1D45"), Color(hex: "1E56A0")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        featureSection
                        productSection
                        restoreSection
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
            }
            .overlay(alignment: .topTrailing) {
                if allowDismissal {
                    Button {
                        dismissAndComplete()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(Color.white.opacity(0.75))
                            .padding()
                    }
                }
            }
            .navigationBarHidden(true)
            .onReceive(storeKitManager.$lastError) { error in
                showError = error != nil
            }
            .onChange(of: storeKitManager.isPremiumUnlocked) { isUnlocked in
                if isUnlocked {
                    dismissAndComplete()
                }
            }
            .onChange(of: storeKitManager.activeSubscription) { subscription in
                selectedProductID = subscription?.id
            }
            .alert("Something went wrong", isPresented: $showError, presenting: storeKitManager.lastError) { _ in
                Button("OK", role: .cancel) { }
            } message: { error in
                Text(error)
            }
            .task {
                if storeKitManager.availableProducts.isEmpty {
                    await storeKitManager.updateProducts()
                }
                selectedProductID = storeKitManager.activeSubscription?.id
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(reason?.title ?? "Upgrade to Premium")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)

            Text(reason?.subtitle ?? "Unlock deeper analytics, premium programs, and unlimited history across LevelUp.")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 48)
    }

    private var featureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(features) { feature in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(hex: "8AD7FF"))
                        .frame(width: 32, height: 32)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        Text(feature.detail)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.75))
                    }
                }
                .padding()
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private var productSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose your plan")
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.white)

            if storeKitManager.availableProducts.isEmpty {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(spacing: 12) {
                    ForEach(storeKitManager.availableProducts, id: \.id) { product in
                        Button {
                            selectedProductID = product.id
                            Task {
                                await storeKitManager.purchase(product)
                            }
                        } label: {
                            HStack(alignment: .center, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(title(for: product))
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    Text(subtitle(for: product))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(product.displayPrice)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "0E1D45"))
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(selectedProductID == product.id ? Color(hex: "40C4FC") : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(storeKitManager.purchaseInProgress)
                    }

                    if storeKitManager.purchaseInProgress {
                        ProgressView("Processing…")
                            .progressViewStyle(.circular)
                            .tint(.white)
                    }
                }
            }
        }
    }

    private var restoreSection: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await storeKitManager.restorePurchases()
                }
            } label: {
                Text("Restore purchases")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.85))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Capsule())
            }

            if allowDismissal {
                Button {
                    dismissAndComplete()
                } label: {
                    Text("Maybe later")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.75))
                        .padding(.vertical, 12)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func dismissAndComplete() {
        dismiss()
        onCompletion?()
    }

    private func title(for product: Product) -> String {
        if let tier = StoreKitManager.SubscriptionTier(rawValue: product.id) {
            return tier.marketingName
        }
        return product.displayName
    }

    private func subtitle(for product: Product) -> String {
        if let tier = StoreKitManager.SubscriptionTier(rawValue: product.id) {
            return tier.marketingBlurb
        }
        return "Full access"
    }
}

private struct PaywallFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let detail: String
}

#Preview {
    PaywallView(allowDismissal: true)
        .environmentObject(StoreKitManager.shared)
}
