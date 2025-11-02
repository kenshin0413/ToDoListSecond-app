//
//  HomeView.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/01.
//

import SwiftUI

struct HomeView: View {
    @StateObject var HomeVM = HomeViewModel()
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                List {
                    ForEach($HomeVM.todoList) { $item in
                        HStack {
                            Button {
                                HomeVM.toggleTask(item)
                            } label: {
                                Image(systemName: item.isChecked ? "checkmark.square" : "square")
                            }
                            Text(item.task)
                        }
                        
                        TextEditor(text: $item.memo)
                            .frame(height: 60)
                            .border(Color.black, width: 0.5)
                            .onChange(of: item.memo) {
                                HomeVM.saveTasks()
                            }
                    }
                    .onDelete(perform: HomeVM.remove)
                    .onMove(perform: HomeVM.moveTask)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        HomeVM.showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("ToDoList")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $HomeVM.showAddTask) {
            AddTaskView(HomeVM: HomeVM)
        }
    }
}

#Preview {
    HomeView()
}
