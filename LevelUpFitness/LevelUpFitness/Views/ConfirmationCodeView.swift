////
////  ConfirmationCodeView.swift
////  LevelUpFitness
////
////  Created by Shriram Vasudevan on 5/25/24.
////
//
//import SwiftUI
//import Combine
//
//struct ConfirmationCodeView: View {
//    @Environment(\.dismiss) var dismiss
//    
//    let email: String
//    
//    @State private var codeDigits: [String] = Array(repeating: "", count: 6)
//    @State private var codeError: Bool = false
//    @FocusState private var focusedField: Int?
//    
//    private let accentColor = Color(hex: "40C4FC")
//    private let backgroundColor = Color.white
//    private let textColor = Color.black
//    private let placeholderColor = Color.gray.opacity(0.7)
//    
//    @State private var resendSuccess: Bool = false
//    @State private var resendError: Error?
//    @State private var isResendingCode: Bool = false
//    
//    @State var navigateToLoginView: Bool = false
//    var body: some View {
//        ZStack {
//            backgroundColor.ignoresSafeArea()
//            
//            VStack(spacing: 24) {
//                VStack(alignment: .center, spacing: 8) {
//                    Text("Verify Your Email")
//                        .font(.system(size: 28, weight: .bold))
//                        .foregroundColor(textColor)
//                    Text("Enter the 6-digit code sent to \(email)")
//                        .font(.system(size: 16, weight: .regular))
//                        .foregroundColor(placeholderColor)
//                        .multilineTextAlignment(.center)
//                }
//                
//                HStack(spacing: 12) {
//                    ForEach(0..<6) { index in
//                        CodeDigitInput(text: $codeDigits[index], fieldIndex: index)
//                            .focused($focusedField, equals: index)
//                            .onChange(of: codeDigits[index]) { newValue in
//                                if newValue.count == 1 {
//                                    if index < 5 {
//                                        focusedField = index + 1
//                                    } else {
//                                        focusedField = nil
//                                    }
//                                } else if newValue.isEmpty {
//                                    if index > 0 {
//                                        focusedField = index - 1
//                                    }
//                                }
//                            }
//                    }
//                }
//                
//                if codeError {
//                    Text("Invalid code. Please try again.")
//                        .font(.system(size: 14, weight: .regular))
//                        .foregroundColor(.red)
//                }
//                
//                Button(action: checkFieldsAndConfirm) {
//                    Text("Verify")
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 56)
//                        .background(accentColor)
//                        .cornerRadius(8)
//                }
//                
//                Button(action: resendConfirmationCode) {
//                    Text(isResendingCode ? "Resending..." : "Resend Code")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.blue)
//                }
//                .padding()
//                .disabled(isResendingCode) 
//
//                if resendSuccess {
//                    Text("Confirmation code has been resent to your email.")
//                        .foregroundColor(.green)
//                }
//
//                if let resendError = resendError {
//                    Text("Failed to resend code: \(resendError.localizedDescription)")
//                        .foregroundColor(.red)
//                }
//                
//                Spacer()
//            }
//            .padding(.horizontal, 24)
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationBarBackButtonHidden(true)
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: { dismiss() }) {
//                    Image(systemName: "chevron.left")
//                        .foregroundColor(.black)
//                }
//            }
//        }
//        .onAppear {
//            focusedField = 0
//        }
//        .navigationDestination(isPresented: $navigateToLoginView) {
//            LoginView()
//        }
//    }
//
//    private func checkFieldsAndConfirm() {
//        let code = codeDigits.joined()
//        codeError = code.count != 6
//        
//        if !codeError {
//            Task {
//                await AuthenticationManager.shared.confirm(email: email, code: code) { success, error in
//                    if success {
//                        navigateToLoginView = true
//                    } else {
//                        codeError = true
//                    }
//                }
//            }
//        }
//    }
//    
//    private func resendConfirmationCode() {
//        isResendingCode = true
//        Task {
//            await AuthenticationManager.shared.resendCode(email: email) { success, error in
//                isResendingCode = false
//                resendSuccess = success
//                resendError = error
//            }
//        }
//    }
//}
//
//struct CodeDigitInput: View {
//    @Binding var text: String
//    let fieldIndex: Int
//    
//    var body: some View {
//        TextField("", text: $text)
//            .keyboardType(.numberPad)
//            .textContentType(.oneTimeCode)
//            .multilineTextAlignment(.center)
//            .frame(width: 50, height: 60)
//            .background(Color(hex: "F5F5F5"))
//            .cornerRadius(8)
//            .overlay(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(Color(hex: "40C4FC"), lineWidth: 2)
//            )
//            .onChange(of: text) { newValue in
//                // Limit the input to 1 character
//                if newValue.count > 1 {
//                    text = String(newValue.prefix(1))
//                }
//            }
//    }
//}
//
//
//
//#Preview {
//    ConfirmationCodeView(email: "shriram123")
//}
