//
//  HomeView.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/01.
//

import SwiftUI

struct ListView: View {
    @EnvironmentObject var ListVM: ListViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Picker("並び替え", selection: $ListVM.sortOption) {
                    ForEach(SortOption.allCases, id: \.self) { opt in
                        Text(opt.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: ListVM.sortOption) {
                    ListVM.sortTask()
                }
                .padding()
                List {
                    ForEach($ListVM.todoList) { $item in
                        VStack {
                            HStack {
                                Button {
                                    ListVM.toggleTask(item)
                                    ListVM.sortTask()
                                } label: {
                                    Image(systemName: item.isChecked ? "checkmark.square" : "square")
                                }
                                Text(item.task)
                                    .strikethrough(item.isChecked, color: .gray)
                                    .foregroundColor(item.isChecked ? Color.gray : Color.primary)
                            }
                            
                            TextEditor(text: $item.memo)
                                .frame(minHeight: 40)
                                .border(Color.black, width: 0.5)
                                .onChange(of: item.memo) {
                                    ListVM.saveTasks()
                                }
                        }
                    }
                    .onDelete { offsets in
                        ListVM.deleteOffsets = offsets
                        ListVM.showDeleteAlert = true
                    }
                    .onMove(perform: ListVM.moveTask)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        ListVM.showAddTask = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .navigationTitle("ToDoList")
            .navigationBarTitleDisplayMode(.inline)
            .alert("このタスクを削除しますか？", isPresented: $ListVM.showDeleteAlert) {
                Button("削除", role: .destructive) {
                    if let offsets = ListVM.deleteOffsets {
                        ListVM.remove(index: offsets)
                        // もう削除対象はないのでリセットする
                        ListVM.deleteOffsets = nil
                    }
                }
                
                Button("キャンセル", role: .cancel) {
                    ListVM.deleteOffsets = nil
                }
            } message: {
                Text("この操作は取り消せません")
            }
        }
        .sheet(isPresented: $ListVM.showAddTask) {
            AddTaskView(ListVM: ListVM)
        }
    }
}

#Preview {
    ListView()
}

