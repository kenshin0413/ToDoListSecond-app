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
                Picker("並び替え", selection: $HomeVM.sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { opt in
                        Text(opt.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: HomeVM.sortOption) {
                    HomeVM.sortTask()
                }
                .padding()
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
                    .onDelete { offsets in
                        HomeVM.deleteOffsets = offsets
                        HomeVM.showDeleteAlert = true
                    }
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
            .alert("このタスクを削除しますか？", isPresented: $HomeVM.showDeleteAlert) {
                Button("削除", role: .destructive) {
                    if let offsets = HomeVM.deleteOffsets {
                        HomeVM.remove(index: offsets)
                        // もう削除対象はないのでリセットする
                        HomeVM.deleteOffsets = nil
                    }
                }
                
                Button("キャンセル", role: .cancel) {
                    HomeVM.deleteOffsets = nil
                }
            } message: {
                Text("この操作は取り消せません")
            }
        }
        .sheet(isPresented: $HomeVM.showAddTask) {
            AddTaskView(HomeVM: HomeVM)
        }
    }
}

#Preview {
    HomeView()
}
