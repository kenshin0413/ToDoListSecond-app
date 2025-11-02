//
//  ContentView.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/10/31.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var HomeVM: HomeViewModel
    @Environment(\.dismiss) var dismiss
    @State var addTask = ""
    var body: some View {
        VStack {
            TextField("追加するタスクを入力", text: $addTask)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button("追加") {
                HomeVM.todoList.append(ToDoItem(isChecked: false, task: addTask))
                HomeVM.saveTasks()
                addTask = ""
                dismiss()
            }
            .foregroundColor(.white)
            .frame(width: 60, height: 30)
            .background(Color.blue)
            .clipShape(.capsule)
        }
        .padding()
    }
}

#Preview {
    AddTaskView(HomeVM: HomeViewModel())
}
