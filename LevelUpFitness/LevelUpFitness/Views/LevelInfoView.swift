import SwiftUI

struct LevelInfoView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(hex: "F3F5F8")
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    introCard
                    sublevelsCard
                    dynamicLevelingCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private var header: some View {
        HStack {
            Text("Level System")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Color(hex: "111827"))

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "6B7280"))
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Understand Your Physical Journey")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Your level reflects training quality, consistency, and recovery. Use these sublevels to see where progress is strongest and where to improve next.")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.88))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(hex: "0B5ED7"), Color(hex: "1C9BFF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var sublevelsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Primary Sublevels")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            HStack(spacing: 10) {
                SubLevelCircularWidget(level: 1, image: "Dumbbell", name: "Strength")
                SubLevelCircularWidget(level: 1, image: "Running", name: "Endurance")
                SubLevelCircularWidget(level: 1, image: "360", name: "Mobility")
            }

            HStack(spacing: 10) {
                Image("PrimarySublevels")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 96)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text("Strength Check")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "111827"))

                    Text("Use this visual as a quick map of how your core training dimensions contribute to level movement.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "6B7280"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private var dynamicLevelingCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dynamic Leveling")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(hex: "111827"))

            bullet("Improve sublevels and complete scheduled sessions to raise your level.")
            bullet("Missing sessions for multiple weeks or declining performance can reduce level.")
            bullet("The system looks at longer trends so one off days do not heavily impact progress.")

            Text("Use your weekly trend views to see what is moving the needle and adjust your plan early.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
                .padding(.top, 2)
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(Color(hex: "0B5ED7"))
                .frame(width: 6, height: 6)
                .padding(.top, 5)

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(hex: "374151"))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    LevelInfoView()
}
