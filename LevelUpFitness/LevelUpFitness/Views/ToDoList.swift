//
//  ToDoList.swift
//  LevelUpFitness
//
//  Created by Shriram Vasudevan on 8/27/24.
//

import SwiftUI

struct ToDoList: View {
    @ObservedObject var toDoListManager = ToDoListManager.shared
    
    var body: some View {
        VStack {
            if toDoListManager.toDoList.count > 0 {
                ForEach(toDoListManager.toDoList, id: \.id) { toDoListTask in
                    HStack {
                        Text(toDoListTask.description)
                        
                        Spacer()
                        
                        Image(systemName: toDoListTask.completed ? "checkmark.seal.fill" : "circle")
                            .foregroundColor(toDoListTask.completed ? .green : .black)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.bottom)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
        )
    }
}

#Preview {
    ToDoList()
}
