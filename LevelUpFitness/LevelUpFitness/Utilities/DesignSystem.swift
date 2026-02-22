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
        
        // Neutrals (Re-mapped for pressurized depth)
        static let backgroundDark = Color.black
        static let backgroundSurface = Color(hex: "111827") // Deep slate
        static let surfaceLight = Color(hex: "1F2937")
        
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "9CA3AF") // Muted gray
        
        static let success = Color(hex: "059669")
        static let danger = Color(hex: "DC2626")
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
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .shadow(
                color: Color.black.opacity(isElevated ? 0.4 : 0.2),
                radius: isElevated ? 20 : 10,
                x: 0,
                y: isElevated ? 10 : 5
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
