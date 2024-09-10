import SwiftUI

struct RegisterView: View {
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
    
    @State private var emailError: Bool = false
    @State private var usernameError: Bool = false
    @State private var nameError: Bool = false
    @State private var passwordError: Bool = false
    
    @State private var navigateToConfirm: Bool = false
    @State private var accountConfirmed: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    private let accentColor = Color(hex: "40C4FC")
    private let textColor = Color.black
    private let placeholderColor = Color.gray.opacity(0.7)
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Create an Account")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(textColor)
                            Text("Join us to start your fitness journey")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(placeholderColor)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 16) {
                            CustomTextField(placeholder: "Email", text: $email, isSecure: false, error: emailError)
                            CustomTextField(placeholder: "Username", text: $username, isSecure: false, error: usernameError)
                            CustomTextField(placeholder: "Name", text: $name, isSecure: false, error: nameError)
                            CustomTextField(placeholder: "Password", text: $password, isSecure: true, error: passwordError)
                        }
                        
                        Button(action: checkFieldsAndSignUp) {
                            Text("Register")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(accentColor)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                }
                .animation(.easeOut(duration: 0.16), value: keyboardResponder.keyboardHeight)
                
                Spacer()
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Already have an account?")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(placeholderColor)
                        Button(action: { dismiss() }) {
                            Text("Sign In")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(accentColor)
                        }
                    }
                    
                    Text("By signing up, you agree to our Terms and Conditions.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(placeholderColor)
                        .multilineTextAlignment(.center)
                }
            }
            
            
        }
        .onChange(of: accountConfirmed) { newValue in
            if newValue {
                dismiss()
            }
        }
        .navigationDestination(isPresented: $navigateToConfirm) {
            ConfirmationCodeView(accountConfirmed: $accountConfirmed, email: email)
        }
        .navigationBarBackButtonHidden(true)
    }

    

    
    private func checkFieldsAndSignUp() {
        emailError = email.isEmpty
        usernameError = username.isEmpty
        nameError = name.isEmpty
        passwordError = password.isEmpty
        
        if !emailError && !usernameError && !nameError && !passwordError {
            Task {
                await AuthenticationManager.shared.register(email: email, name: name, username: username, password: password) { success, userID, failed in
                    if success {
                        navigateToConfirm = true
                    }
                }
            }
        }
    }
}


#Preview {
    RegisterView()
}
