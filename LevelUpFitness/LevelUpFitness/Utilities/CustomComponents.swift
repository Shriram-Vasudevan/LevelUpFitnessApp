//
//  CustomComponents.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan.
//

import SwiftUI

/// A massive, premium action button that shatters the default iOS look.
struct PremiumActionButton: View {
    var title: String
    var icon: String? = nil
    var action: () -> Void
    var style: ActionStyle = .primary
    
    enum ActionStyle {
        case primary
        case secondary
        case destructive
    }
    
    var backgroundColor: Color {
        switch style {
        case .primary: return AppTheme.Colors.bluePrimary
        case .secondary: return AppTheme.Colors.surfaceLight
        case .destructive: return AppTheme.Colors.danger.opacity(0.1)
        }
    }
    
    var foregroundColor: Color {
        switch style {
        case .primary: return .white
        case .secondary: return AppTheme.Colors.bluePrimary
        case .destructive: return AppTheme.Colors.danger
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                }
                Text(title)
                    .font(AppTheme.Typography.telemetry(size: 18, weight: .bold))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous)
                    .stroke(style == .secondary ? AppTheme.Colors.bluePrimary.opacity(0.3) : .clear, lineWidth: 2)
            )
            .controlledGlow(isActive: style == .primary, color: AppTheme.Colors.bluePrimary.opacity(0.3))
        }
        .buttonStyle(KineticButtonStyle())
    }
}

/// A bespoke, beautiful text input that throws out the standard form look.
struct EngineeredTextField: View {
    var title: String
    @Binding var text: String
    var placeholder: String
    var icon: String? = nil
    var isSecure: Bool = false
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 13, weight: .bold))
                .foregroundColor(AppTheme.Colors.textSecondary)
                .textCase(.uppercase)
            
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isFocused ? AppTheme.Colors.bluePrimary : AppTheme.Colors.textSecondary)
                        .font(.system(size: 20))
                }
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .focused($isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .focused($isFocused)
                }
            }
            .font(AppTheme.Typography.telemetry(size: 18, weight: .medium))
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppTheme.Colors.surfaceLight)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Geometry.tightRadius, style: .continuous)
                    .stroke(isFocused ? AppTheme.Colors.bluePrimary : Color.black.opacity(0.05), lineWidth: isFocused ? 2 : 1)
            )
            .shadow(color: isFocused ? AppTheme.Colors.bluePrimary.opacity(0.15) : .clear, radius: 8, x: 0, y: 4)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
        }
    }
}

/// Custom tactile toggle
struct KineticToggle: View {
    var title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(AppTheme.Typography.telemetry(size: 16, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
            
            Spacer()
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isOn.toggle()
                }
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(isOn ? AppTheme.Colors.bluePrimary : AppTheme.Colors.textSecondary.opacity(0.2))
                        .frame(width: 52, height: 32)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                        .offset(x: isOn ? 10 : -10)
                }
            }
            .buttonStyle(KineticButtonStyle())
        }
        .padding(.vertical, 8)
    }
}
