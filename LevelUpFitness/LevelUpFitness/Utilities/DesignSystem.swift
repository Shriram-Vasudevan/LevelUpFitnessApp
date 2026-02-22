import SwiftUI

/// Core Design System for LevelUp Fitness
/// "Engineered Motion" & "Kinetic Precision" Aesthetic
struct AppTheme {
    
    // MARK: - Colors
    // Maintaining existing app color system (Brand Blues, Neutrals)
    struct Colors {
        // Brand Blues
        static let blueDark = Color(hex: "0B5ED7")
        static let bluePrimary = Color(hex: "1C9BFF")
        static let blueLight = Color(hex: "2A7FFF")
        static let blueTint = Color(hex: "E8F3FF")
        
        // Neutrals (Re-mapped for pristine light mode)
        static let backgroundDark = Color(hex: "F8F9FA") // Main background is now light gray
        static let backgroundSurface = Color.white // Panels are pure white
        static let surfaceLight = Color.white // Elevated surfaces are pure white
        
        static let textPrimary = Color.black // Text is black
        static let textSecondary = Color(hex: "6B7280") // Muted slate gray
        
        static let success = Color(hex: "10B981") // Brighter success for light mode
        static let danger = Color(hex: "EF4444") // Brighter danger for light mode
    }
    
    // MARK: - Gradients & Glows
    struct Lighting {
        static let activeGradient = LinearGradient(
            colors: [Colors.blueDark, Colors.bluePrimary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        static let activeGlow = Colors.bluePrimary.opacity(0.3)
    }
    
    // MARK: - Typography
    struct Typography {
        /// Monospaced for dynamic numerical data. Stable. Engineered.
        static func monumentalNumber(size: CGFloat) -> Font {
            .system(size: size, weight: .bold, design: .monospaced)
        }
        
        /// Tight tracking geometric sans-serif for primary text
        static func telemetry(
            size: CGFloat,
            weight: Font.Weight = .regular,
            tracking: CGFloat = -0.5
        ) -> Font {
            .system(size: size, weight: weight, design: .rounded) // Rounded design for softer, aerodynamic feel if preferred, else standard
        }
    }
    
    // MARK: - Geometry & Shapes
    struct Geometry {
        static let aerodynamicRadius: CGFloat = 16
        static let tightRadius: CGFloat = 10
        static let macroRadius: CGFloat = 24
    }
}

// MARK: - Core View Modifiers

/// Panel mapping for "Depth Stack"
struct EngineeredPanel: ViewModifier {
    var isElevated: Bool = false
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous)
                    .fill(AppTheme.Colors.backgroundSurface)
            )
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Geometry.aerodynamicRadius, style: .continuous)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(isElevated ? 0.12 : 0.06),
                radius: isElevated ? 15 : 8,
                x: 0,
                y: isElevated ? 8 : 4
            )
    }
}

/// Kinetic Button pressing physics
struct KineticButtonPressModifier: ViewModifier {
    let isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.6, blendDuration: 0.2), value: isPressed)
    }
}

struct KineticButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(KineticButtonPressModifier(isPressed: configuration.isPressed))
    }
}

/// Subtle Glow for active components
struct ControlledGlow: ViewModifier {
    var isActive: Bool
    var color: Color = AppTheme.Lighting.activeGlow
    
    func body(content: Content) -> some View {
        content
            .shadow(color: isActive ? color : .clear, radius: 15, x: 0, y: 0)
    }
}

extension View {
    func engineeredPanel(isElevated: Bool = false) -> some View {
        modifier(EngineeredPanel(isElevated: isElevated))
    }
    
    func controlledGlow(isActive: Bool = true, color: Color = AppTheme.Lighting.activeGlow) -> some View {
        modifier(ControlledGlow(isActive: isActive, color: color))
    }
}
