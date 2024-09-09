import SwiftUI

struct ToDoList: View {
    @ObservedObject var toDoListManager = ToDoListManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's To Do")
                    .font(.system(size: 22, weight: .medium, design: .default))
                
                Spacer()
                
                Text(DateUtility.getCurrentDate())
                    .font(.system(size: 14, weight: .regular, design: .default))
                    .foregroundColor(.gray)
            }
            
            if toDoListManager.toDoList.count > 0 {
                ForEach(toDoListManager.toDoList, id: \.id) { toDoListTask in
                    HStack(spacing: 12) {
                        Image(systemName: toDoListTask.completed ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(toDoListTask.completed ? Color(hex: "40C4FC") : .gray)
                            .font(.system(size: 20))
                        
                        Text(toDoListTask.description)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(toDoListTask.completed ? .gray : .black)
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
            } else {
                Text("No tasks for today")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            
        }
    }
}

#Preview {
    ToDoList()
}
