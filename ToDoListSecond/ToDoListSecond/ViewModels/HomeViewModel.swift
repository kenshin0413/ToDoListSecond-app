//
//  HomeViewModel.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/01.
//

import Foundation
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var showAddTask = false
    @Published var addTask = ""
    @Published var todoList: [ToDoItem] = [ToDoItem(isChecked: false, task: "買い物に行く"), ToDoItem(isChecked: false, task: "ジムに行く"), ToDoItem(isChecked: false, task: "塾に行く")]
    @Published var deleteOffsets: IndexSet?
    @Published var showDeleteAlert = false
    @Published var sortOption: SortOption = .new
    init() {
        loadTask()
    }
    
    let taskkey = "todoList"
    // 保存処理
    func saveTasks() {
        if let data = try? JSONEncoder().encode(todoList) {
            UserDefaults.standard.set(data, forKey: taskkey)
        }
    }
    // チェック切り替え
    func toggleTask(_ item: ToDoItem) {
        if let index = todoList.firstIndex(where: { $0.id == item.id }) {
            todoList[index].isChecked.toggle()
            saveTasks()
        }
    }
    // 読み込み処理
    func loadTask() {
        if let data = UserDefaults.standard.data(forKey: taskkey) {
            if let saveTasks = try? JSONDecoder().decode([ToDoItem].self, from: data) {
                todoList = saveTasks
            }
        }
    }
    
    func remove(index: IndexSet) {
        todoList.remove(atOffsets: index)
        saveTasks()
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        todoList.move(fromOffsets: source, toOffset: destination)
        saveTasks()
    }
    
    func sortTask() {
        switch sortOption {
        case .new:
             todoList.sort {
                $0.createdAt > $1.createdAt
            }
        case .old:
             todoList.sort {
                $0.createdAt < $1.createdAt
            }
        }
        saveTasks()
    }
}
