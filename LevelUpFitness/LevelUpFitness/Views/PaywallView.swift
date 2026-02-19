//
//  PaywallView.swift
//  LevelUpFitness
//
//  Created by OpenAI Assistant on 10/7/24.
//

import SwiftUI
import StoreKit
import Charts

struct PaywallView: View {
    @EnvironmentObject private var storeKitManager: StoreKitManager
    @Environment(\.dismiss) private var dismiss

    var allowDismissal: Bool
    var onCompletion: (() -> Void)?

    @State private var selectedProductID: String?
    @State private var showError: Bool = false

    private var reason: StoreKitManager.PaywallTriggerReason? {
        storeKitManager.lastPaywallTrigger
    }

    private var selectedProduct: Product? {
        if let selectedProductID {
            return storeKitManager.availableProducts.first(where: { $0.id == selectedProductID })
        }
        return storeKitManager.availableProducts.first
    }

    private var features: [PaywallFeature] {
        [
            PaywallFeature(icon: "chart.xyaxis.line", title: "Pro analytics", detail: "Clean trend dashboards for volume, reps, rest, and streaks."),
            PaywallFeature(icon: "square.grid.2x2", title: "Multi-programs", detail: "Join and manage multiple active programs from one hub."),
            PaywallFeature(icon: "person.2.fill", title: "Squad training", detail: "Build friend sessions, challenge cards, and shared goals."),
            PaywallFeature(icon: "clock.arrow.circlepath", title: "Full history", detail: "Unlimited access to past sessions and program insights.")
        ]
    }

    private var chartPoints: [PaywallTrendPoint] {
        [
            PaywallTrendPoint(label: "W1", value: 42),
            PaywallTrendPoint(label: "W2", value: 49),
            PaywallTrendPoint(label: "W3", value: 58),
            PaywallTrendPoint(label: "W4", value: 65),
            PaywallTrendPoint(label: "W5", value: 74)
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                Color(hex: "F4F6F8")
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        headerSection
                        trendSection
                        featuresSection
                        productsSection
                        restoreSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                }

                if allowDismissal {
                    Button {
                        dismissAndComplete()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(hex: "1A1D24"))
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .padding(.top, 16)
                    .padding(.trailing, 20)
                }
            }
            .navigationBarHidden(true)
            .onReceive(storeKitManager.$lastError) { error in
                showError = error != nil
            }
            .onChange(of: storeKitManager.effectiveIsPremiumUnlocked) { isUnlocked in
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
                selectedProductID = storeKitManager.activeSubscription?.id ?? storeKitManager.availableProducts.first?.id
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(reason?.title ?? "Upgrade to Premium")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: "111827"))
                .multilineTextAlignment(.leading)

            Text(reason?.subtitle ?? "Unlock a cleaner training workflow with advanced insights, friend sessions, and full program history.")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "4B5563"))
                .multilineTextAlignment(.leading)

            HStack(spacing: 8) {
                paywallTag("No ads")
                paywallTag("Cancel anytime")
                paywallTag("Synced across devices")
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func paywallTag(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(Color(hex: "1F3C88"))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(hex: "DCE9FF"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Typical progress after unlocking Premium")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(hex: "374151"))

            Chart(chartPoints) { point in
                AreaMark(
                    x: .value("Week", point.label),
                    y: .value("Progress", point.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "1C9BFF").opacity(0.25), Color(hex: "1C9BFF").opacity(0.04)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Week", point.label),
                    y: .value("Progress", point.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 3))
                .foregroundStyle(Color(hex: "1C9BFF"))

                PointMark(
                    x: .value("Week", point.label),
                    y: .value("Progress", point.value)
                )
                .foregroundStyle(Color(hex: "0B5ED7"))
            }
            .frame(height: 150)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var featuresSection: some View {
        VStack(spacing: 10) {
            ForEach(features) { feature in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: feature.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(hex: "0B5ED7"))
                        .frame(width: 28, height: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))
                        Text(feature.detail)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color(hex: "4B5563"))
                    }

                    Spacer(minLength: 0)
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.black.opacity(0.08), lineWidth: 1)
                )
            }
        }
    }

    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Choose your plan")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            if storeKitManager.availableProducts.isEmpty {
                productLoadingState
            } else {
                VStack(spacing: 10) {
                    ForEach(storeKitManager.availableProducts, id: \.id) { product in
                        planRow(for: product)
                    }

                    Button {
                        guard let selectedProduct else { return }
                        Task {
                            await storeKitManager.purchase(selectedProduct)
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if storeKitManager.purchaseInProgress {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Continue")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            Spacer()
                        }
                        .padding(.vertical, 14)
                        .background(Color(hex: "0B5ED7"))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(storeKitManager.purchaseInProgress || selectedProduct == nil)
                }
            }
        }
    }

    private var productLoadingState: some View {
        VStack(spacing: 12) {
            if storeKitManager.isLoadingProducts {
                ProgressView()
                    .tint(Color(hex: "0B5ED7"))
                Text("Loading plans...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "4B5563"))
            } else if let error = storeKitManager.productLoadError {
                Text(error)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "4B5563"))
                    .multilineTextAlignment(.center)

                Button("Retry") {
                    Task {
                        await storeKitManager.updateProducts()
                    }
                }
                .font(.system(size: 14, weight: .semibold))
            } else {
                Text("No subscription plans are currently available.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "4B5563"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func planRow(for product: Product) -> some View {
        let isSelected = selectedProductID == product.id
        let isRecommended = StoreKitManager.SubscriptionTier(rawValue: product.id) == .annual

        return Button {
            selectedProductID = product.id
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .strokeBorder(isSelected ? Color(hex: "0B5ED7") : Color(hex: "9CA3AF"), lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? Color(hex: "0B5ED7") : .clear)
                            .padding(4)
                    )
                    .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title(for: product))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "111827"))
                        if isRecommended {
                            Text("Best value")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color(hex: "0B5ED7"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "DCE9FF"))
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        }
                    }

                    Text(subtitle(for: product))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "111827"))
            }
            .padding(14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(isSelected ? Color(hex: "0B5ED7") : Color.black.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(storeKitManager.purchaseInProgress)
    }

    private var restoreSection: some View {
        VStack(spacing: 12) {
            Button("Restore purchases") {
                Task {
                    await storeKitManager.restorePurchases()
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(Color(hex: "0B5ED7"))

            if allowDismissal {
                Button("Not now") {
                    dismissAndComplete()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
            }
        }
        .padding(.top, 4)
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

private struct PaywallTrendPoint: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

#Preview {
    PaywallView(allowDismissal: true)
        .environmentObject(StoreKitManager.shared)
}
