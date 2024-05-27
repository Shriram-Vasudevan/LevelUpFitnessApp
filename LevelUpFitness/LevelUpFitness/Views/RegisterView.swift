//
//  RegisterView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI


struct RegisterView: View {
    @ObservedObject var authenticationManager: AuthenticationManager
    
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var name: String = ""
    @State private var password: String = ""
//    @State private var confirmPassword: String = ""
    
    @State var emailUnfilled: Bool = false
    @State var usernameUnfilled: Bool = false
    @State var nameUnfilled: Bool = false
    @State var passwordUnfilled: Bool = false
//    @State var confirmPasswordUnfilled: Bool = false
//    @State var passwordsDontMatch: Bool = false
    
    @State var navigateToConfirm: Bool = false
        @State var accountConfirmed: Bool = false
    
    @Environment(\.dismiss) var dismiss

    
    var customGrey: Color = Color(red: 248/255.0, green: 252/255.0, blue: 252/255.0)
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Text("Let's Create an \nAccount!")
                            .foregroundColor(.black)
                            .font(.custom("Sailec Bold", size: 35))
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 40)
                    

             
                    CustomTextField(placeholder: Text("Email").foregroundColor(.gray), text: $email)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(emailUnfilled ? .red.opacity(0.7) : customGrey))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(emailUnfilled ? .red : .gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)
                        .padding(.bottom, 15)
                    
                    CustomTextField(placeholder: Text("Username").foregroundColor(.gray), text: $username)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(usernameUnfilled ? .red.opacity(0.7) : customGrey))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(usernameUnfilled ? .red : .gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)
                        .padding(.bottom, 15)
                    
                    CustomTextField(placeholder: Text("Name").foregroundColor(.gray), text: $name)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(nameUnfilled ? .red.opacity(0.7) : customGrey))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(nameUnfilled ? .red : .gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                        .autocapitalization(.none)
                        .padding(.bottom, 15)

               
                    CustomSecureField(placeholder: Text("Password").foregroundColor(.gray), text: $password)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(passwordUnfilled ? .red.opacity(0.7) : customGrey))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(passwordUnfilled ? .red : .gray.opacity(0.3), lineWidth: 1))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 15)
                    


                  
                    Button(action: {
                        withAnimation {
                            checkFieldsAndSignUp()
                        }
                    }) {
                        Text("Register")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(20)
                            .background(.black)
                            .cornerRadius(7)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 15)
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text("Already have an account?")
                                .font(.footnote)
                                .foregroundColor(.black)
                                .bold()
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Sign In")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .bold()
                                    .foregroundColor(Color.blue)
                            }
                        }
                        .padding(.top, 20)
                        
                        Text("By signing up, you agree to our Terms and Conditions.")
                            .font(.footnote)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .bold()
                            .padding(.top, 5)
                            .padding(.bottom, 20)
                    }

                }
            }
            .onChange(of: accountConfirmed, perform: { newValue in
                if newValue {
                    dismiss()
                }
            })
            .navigationDestination(isPresented: $navigateToConfirm) {
                ConfirmationCodeView(email: email, accountConfirmed: $accountConfirmed)
            }
            .navigationBarBackButtonHidden()
        }
    }
    
    func checkFieldsAndSignUp() {
        emailUnfilled = email.isEmpty
        usernameUnfilled = username.isEmpty
        nameUnfilled = name.isEmpty
        passwordUnfilled = password.isEmpty
        
        if (!emailUnfilled && !usernameUnfilled && !nameUnfilled && !passwordUnfilled) {
            Task {
                await authenticationManager.register(email: email, name: name, username: username, password: password) { success, userID, failed in
                    print("something")
                    if success {
                        print("success")
                        navigateToConfirm = true
                    } else {
                        print("failed")
                    }
                }
            }
        }
    }
}


#Preview {
    RegisterView(authenticationManager: AuthenticationManager())
}
