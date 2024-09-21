import SwiftUI

struct ToDoList: View {
    @ObservedObject var toDoListManager: ToDoListManager
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if toDoListManager.toDoList.isEmpty {
                Text("No tasks for today")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.vertical, 4)
            } else {
                ForEach(toDoListManager.toDoList) { task in
                    HStack(spacing: 10) {
                        Image(systemName: task.completed ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.completed ? Color(hex: "40C4FC") : .gray)
                            .font(.system(size: 16))
                        
                        Text(task.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(task.completed ? .gray : .black)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white)
        .shadow(radius: 2)
        .overlay(
            Rectangle()
                .fill(Color(hex: "40C4FC"))
                .frame(width: 3)
                .padding(.vertical, 4),
            alignment: .leading
        )
    }
}

#Preview {
    ToDoList(toDoListManager: ToDoListManager())
}
