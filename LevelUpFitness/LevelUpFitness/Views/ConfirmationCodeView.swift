//
//  ConfirmationCodeView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 5/25/24.
//

import SwiftUI
import Combine

struct ConfirmationCodeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var authenticationManager = AuthenticationManager()
    @Binding var accountConfirmed: Bool
    
    let email: String
    
    @State private var codeDigits: [String] = Array(repeating: "", count: 6)
    @State private var currentlyEditingField = 0
    @State private var codeError: Bool = false
    
    private let accentColor = Color(hex: "40C4FC")
    private let backgroundColor = Color.white
    private let textColor = Color.black
    private let placeholderColor = Color.gray.opacity(0.7)
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .center, spacing: 8) {
                        Text("Verify Your Email")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(textColor)
                        Text("Enter the 6-digit code sent to \(email)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(placeholderColor)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack(spacing: 12) {
                        ForEach(0..<6) { index in
                            CodeDigitInput(text: $codeDigits[index], currentlyEditingField: $currentlyEditingField, fieldIndex: index)
                        }
                    }
                    
                    Group {
                        if codeError {
                            Text("Invalid code. Please try again.")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.red)
                        }
                    }
                    
                    Button(action: checkFieldsAndConfirm) {
                        Text("Verify")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(accentColor)
                            .cornerRadius(8)
                    }
                    
                    Button(action: resendCode) {
                        Text("Resend Code")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(accentColor)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }


    private func checkFieldsAndConfirm() {
        let code = codeDigits.joined()
        codeError = code.count != 6
        
        if !codeError {
            Task {
                await authenticationManager.confirm(email: email, code: code) { success, error in
                    if success {
                        accountConfirmed = true
                        dismiss()
                    } else {
                        codeError = true
                    }
                }
            }
        }
    }
    
    private func resendCode() {
        
    }
}

struct CodeDigitInput: View {
    @Binding var text: String
    @Binding var currentlyEditingField: Int
    let fieldIndex: Int
    
    var body: some View {
        TextField("", text: $text)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .multilineTextAlignment(.center)
            .frame(width: 50, height: 60)
            .background(Color(hex: "F5F5F5"))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hex: "40C4FC"), lineWidth: currentlyEditingField == fieldIndex ? 2 : 0)
            )
            .onChange(of: text) { newValue in
                DispatchQueue.main.async {
                    if newValue.count > 1 {
                        text = String(newValue.prefix(1))
                    }
                    if !newValue.isEmpty {
                        if fieldIndex < 5 {
                            currentlyEditingField = fieldIndex + 1
                        } else {
                            currentlyEditingField = 5
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                    }
                }
            }
            .onTapGesture {
                currentlyEditingField = fieldIndex
            }
    }
}


#Preview {
    ConfirmationCodeView(accountConfirmed: .constant(false), email: "shriram123")
}
