//
//  ConfirmationCodeView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI

struct ConfirmationCodeView: View {
    @State private var confirmationCode: String = ""
    @State var email: String
    @State private var codeError: Bool = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject private var authenticationManager = AuthenticationManager()
    
    @Binding var accountConfirmed: Bool
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.black)
                            .padding()
                    }
                    
                    Spacer()
                }

                VStack(alignment: .center, spacing: 15) {
                    Text("Enter Confirmation Code")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("We've sent a code to your email. Please enter it below to confirm your account.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    TextField("Confirmation Code", text: $confirmationCode)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .font(Font.system(size: 22, design: .rounded))
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(codeError ? Color.red.opacity(0.1) : Color.white))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(codeError ? Color.red : Color.blue, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                    
                    if codeError {
                        Text("Please enter a valid code.")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        Task {
                            await checkFieldsAndConfirm()
                        }
                    }) {
                        Text("Confirm")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(20)
                            .padding(.horizontal, 20)
                    }
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    func checkFieldsAndConfirm() async {
        codeError = confirmationCode.isEmpty
        
        if !codeError {
            await authenticationManager.confirm(email: email, code: confirmationCode) { success, error in
                if success {
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss()
                        accountConfirmed = true
                    }
                }
            }
        }
    }
}

#Preview {
    ConfirmationCodeView(email: "shriram123", accountConfirmed: .constant(false))
}
