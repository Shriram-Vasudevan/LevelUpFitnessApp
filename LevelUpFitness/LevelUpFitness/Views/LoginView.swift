import SwiftUI

struct LoginView: View {
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: Bool = false
    @State private var passwordError: Bool = false
    
    @State private var navigateToRegister: Bool = false
    @State private var navigateToHomePage: Bool = false
    
    private let accentColor = Color(hex: "40C4FC")
    private let backgroundColor = Color.white
    private let textColor = Color.black
    private let placeholderColor = Color.gray.opacity(0.7)
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(textColor)
                    Text("Sign in to continue")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(placeholderColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    CustomTextField(placeholder: "Email", text: $email, isSecure: false, error: emailError)
                    CustomTextField(placeholder: "Password", text: $password, isSecure: true, error: passwordError)
                }
                
                Button(action: checkFieldsAndLogin) {
                    Text("Log In")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(accentColor)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Handle forgot password
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(accentColor)
                }
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(placeholderColor)
                    Button(action: { navigateToRegister = true }) {
                        Text("Sign Up")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accentColor)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 60)
            .padding(.bottom, keyboardResponder.keyboardHeight)
            .animation(.easeOut(duration: 0.16), value: keyboardResponder.keyboardHeight)
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $navigateToRegister) {
            RegisterView()
        }
        .navigationDestination(isPresented: $navigateToHomePage) {
            PagesHolderView(pageType: .home)
        }
    }
    


    private func checkFieldsAndLogin() {
        emailError = email.isEmpty
        passwordError = password.isEmpty
        
        if !emailError && !passwordError {
            Task {
                await AuthenticationManager.shared.login(username: email, password: password) { success, userID, failed in
                    if success {
                        navigateToHomePage = true
                    }
                }
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let error: Bool
    
    private let accentColor = Color(hex: "40C4FC")
    private let errorColor = Color.red.opacity(0.7)
    private let placeholderColor = Color.gray.opacity(0.7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textFieldStyle(CustomTextFieldStyle(error: error))
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(CustomTextFieldStyle(error: error))
                    .autocapitalization(.none)
            }
            if error {
                Text("\(placeholder) is required")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(errorColor)
            }
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    let error: Bool
    
    private let accentColor = Color(hex: "40C4FC")
    private let errorColor = Color.red.opacity(0.7)
    private let backgroundColor = Color(hex: "F5F5F5")
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(16)
            .background(backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(error ? errorColor : accentColor, lineWidth: error ? 1 : 0)
            )
    }
}

#Preview {
    LoginView()
}
