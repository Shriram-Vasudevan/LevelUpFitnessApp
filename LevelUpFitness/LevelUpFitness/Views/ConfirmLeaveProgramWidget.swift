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
            
            VStack {
                Text("Are you sure?")
                    .bold()
                
                Button(action: {
                    withAnimation {
                        confirmed()
                    }
                }) {
                    Text("Confirm")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(20)
                        .shadow(radius: 3)
                        .padding(.horizontal, 20)
                        .padding(.top)
                }
                
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 5)
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
