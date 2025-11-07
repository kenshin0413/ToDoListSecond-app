//
//  HomeViewModel.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/01.
//

import SwiftUI
import Combine

final class ListViewModel: ObservableObject {
    @Published var todoList: [ToDoItem] = []
    @Published var showAddTask = false
    @Published var showCongrats = false
    @Published var sortOption: SortOption = .new

    private let repository = TaskRepository()
    private let monitor = TaskMonitor()
    private var cancellables = Set<AnyCancellable>()

    init() {
        ListViewModelReference(viewModel: self)
        todoList = repository.load()
        setupBindings()
        NotificationManager.shared.requestPermission()
    }

    private func setupBindings() {
        monitor.autoSave($todoList) { [weak self] list in
            self?.repository.save(list)
        }

        monitor.observeCompletionRate($todoList) { [weak self] in
            self?.showCongrats = true
        }

        monitor.scheduleNotification()
    }

    // ✅ 基本操作群
    func addTask(_ text: String) {
        guard !text.isEmpty else { return }
        todoList.append(ToDoItem(isChecked: false, task: text))
    }

    func toggleTask(_ item: ToDoItem) {
        if let index = todoList.firstIndex(where: { $0.id == item.id }) {
            todoList[index].isChecked.toggle()
            sortTask()
        }
    }

    func sortTask() {
        todoList.sort {
            if $0.isChecked == $1.isChecked {
                switch sortOption {
                case .new:
                    return $0.createdAt > $1.createdAt
                case .old:
                    return $0.createdAt < $1.createdAt
                }
            } else {
                return !$0.isChecked && $1.isChecked
            }
        }
    }
}
