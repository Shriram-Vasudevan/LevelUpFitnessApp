//
//  ChatView.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 6/12/24.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) var dismiss
    @State private var message: String = ""
    @FocusState private var chatFieldIsFocused: Bool
    
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            
            VStack () {
                ZStack {
                    HStack {
                        Button(action: {
                            dismiss()
                        }, label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                        })
                        
                        Text("Close")
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Spacer()
                        
                        Text("Chat")
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                }
                
                VStack {
                    HStack {
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        TextField("Enter a message...", text: $message)
                            .padding(12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(.black.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Button(action: {
                                   
                                    message = ""
                                }, label: {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.blue)
                                        .padding(.trailing, 5)
                                }),
                                alignment: .trailing
                            )
                            .focused($chatFieldIsFocused)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .padding(.bottom)
                }
                .padding(.top)
                .background(
                    Rectangle()
                        .fill(.white)
                )
                .ignoresSafeArea(.all)
            }
        }
    }
}

#Preview {
    ChatView()
}
