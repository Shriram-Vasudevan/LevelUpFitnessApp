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
            
            VStack (spacing: 5) {
                Text("Are you sure?")
                    .font(.system(size: 18, weight: .medium, design: .default))
                    .foregroundColor(.black)
                
                Button(action: {
                    withAnimation {
                        confirmed()
                        close()
                    }
                }) {
                    ZStack {
                        Rectangle() 
                            .fill(Color(hex: "40C4FC"))
                            .cornerRadius(3)
                            .shadow(radius: 3)
                        
                        Text("Confirm")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .padding(.horizontal, 20)
                    .padding(.top)
                }

                
            }
            .padding()
            .background(
                Rectangle()
                    .fill(Color(hex: "F5F5F5"))
            )
            .padding()
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
