import SwiftUI

struct ConfirmLeaveProgramWidget: View {
    @State var offset: CGFloat = 1000
    @Binding var isOpen: Bool
    
    var confirmed: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    close()
                }
            
            VStack (spacing: 20) {
                Text("Are you sure?")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.black)
                
                Button(action: {
                    withAnimation {
                        confirmed()
                        close()
                    }
                }) {
                    
                    Text("Confirm")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Rectangle()
                                .fill(Color(hex: "40C4FC"))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        )
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    withAnimation {
                        close()
                    }
                }) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                }
                .padding(.top, 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "F5F5F5"))
            )
            .padding(.horizontal, 30)
            .offset(x: 0, y: offset)
        }
        .onAppear {
            withAnimation(.spring()) {
                offset = 0
            }
        }
    }
    
    func close() {
        withAnimation(.spring(duration: 1)) {
            offset = 1000
        }
        
        let animationDuration = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            withAnimation {
                isOpen = false
            }
        }
    }
}

#Preview {
    ConfirmLeaveProgramWidget(isOpen: .constant(true), confirmed: {})
}
