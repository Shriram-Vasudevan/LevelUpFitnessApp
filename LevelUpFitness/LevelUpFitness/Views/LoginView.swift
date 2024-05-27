//
//  LoginView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//


import SwiftUI
import AVKit

struct LoginView: View {
    @ObservedObject var authenticationManager = AuthenticationManager()
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var emailError: Bool = false
    @State private var passwordError: Bool = false
    
    @State var navigateToRegister: Bool = false
    @State var navigateToHomePage: Bool = false
    
    @Environment(\.dismiss) var dismiss
    
    var customGrey: Color = Color(red: 248/255.0, green: 252/255.0, blue: 252/255.0)
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    HStack {
                        Text("Welcome Back!")
                            .foregroundColor(.black)
                            .font(.custom("Sailec Bold", size: 35))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                    
                    CustomTextField(placeholder: Text("Email").foregroundColor(.gray), text: $email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(emailError ? .red.opacity(0.7) : customGrey))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(emailError ? .red : .gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)

                    CustomSecureField(placeholder: Text("Password").foregroundColor(.gray), text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(passwordError ? .red.opacity(0.7): customGrey))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(passwordError ? .red : .gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Text("Forgot Password?")
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        withAnimation {
                            checkFieldsAndLogin()
                        }
                    }) {
                        Text("Log In")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(.black)
                            .cornerRadius(7)
                            .shadow(radius: 3)
                            .padding(.horizontal, 20)
                            .padding(.top)
                    }
                    .padding(.bottom, keyboardResponder.keyboardHeight - keyboardResponder.keyboardHeight * 0.5)
                    .animation(.spring(), value: keyboardResponder.keyboardHeight)

                    Spacer()

                    VStack {
                        HStack {
                            Text("Don't have an account?")
                                .font(.footnote)
                                .foregroundColor(.black)
                            
                            Button(action: {
                                navigateToRegister = true
                            }) {
                                Text("Sign Up")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.blue)
                            }
                        }
                        .padding(.top, 20)
                        
                        Text("By signing in, you agree to our Terms and Conditions.")
                            .font(.footnote)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                            .padding(.bottom, 20)
                    }

                }
            }
            .navigationDestination(isPresented: $navigateToRegister) {
                RegisterView(authenticationManager: authenticationManager)
            }
            .navigationDestination(isPresented: $navigateToHomePage) {
                PagesHolderView(pageType: .home)
            }
        }
    }
    
    func checkFieldsAndLogin() {
        emailError = email.isEmpty
        passwordError = password.isEmpty
        
        if (!emailError && !passwordError) {
            Task {
                await authenticationManager.login(username: email, password: password, completion: { success, userID, failed in
                    if success {
                        navigateToHomePage = true
                    }
                })
            }
        }
    }
}

struct CustomTextField: View {
    var placeholder: Text
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text)
                .foregroundColor(.black)
        }
    }
}

struct CustomSecureField: View {
    var placeholder: Text
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            SecureField("", text: $text)
                .foregroundColor(.black)
        }
    }
}


#Preview {
    LoginView()
}


