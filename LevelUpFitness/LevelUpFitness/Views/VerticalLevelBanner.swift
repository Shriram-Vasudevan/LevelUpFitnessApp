import SwiftUI

struct VerticalLevelBanner: View {
    var level: Int
    
    var body: some View {
        VStack {
            Text("level")
                .font(.system(size: 15))
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("\(level)")
                .font(.custom("Sailec Bold", size: 40))
                .foregroundColor(.white)
        }
        .frame(width: 85, height: 85)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.58, green: 0.4, blue: 0.92),
                            Color(red: 0.2, green: 0.5, blue: 0.92)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

#Preview {
    VerticalLevelBanner(level: 5)
}
