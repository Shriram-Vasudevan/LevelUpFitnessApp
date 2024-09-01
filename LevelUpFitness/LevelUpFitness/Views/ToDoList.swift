import SwiftUI

struct ToDoList: View {
    @ObservedObject var toDoListManager = ToDoListManager.shared
    
    var body: some View {
        VStack() {
            HStack {
                Text("Today's To Do")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(DateUtility.getCurrentDate())
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, 5)
            
            if toDoListManager.toDoList.count > 0 {
                ForEach(toDoListManager.toDoList, id: \.id) { toDoListTask in
                    HStack {
                        Image(systemName: toDoListTask.completed ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(toDoListTask.completed ? Color(red: 0.3, green: 0.7, blue: 0.3) : .white)
                            .font(.system(size: 16))
                        
                        Text(toDoListTask.description)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                }
            } else {
                Text("No tasks for today")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 20)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.75, blue: 0.9),
                    Color(red: 0.47, green: 0.87, blue: 0.95)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ToDoList()
}
