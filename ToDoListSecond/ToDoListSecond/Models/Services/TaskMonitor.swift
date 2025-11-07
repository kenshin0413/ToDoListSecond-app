//
//  TaskMonitor.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/07.
//

import Combine
import Foundation

final class TaskMonitor {
    private var cancellables = Set<AnyCancellable>()
    
    // 自動保存（入力が止まって1秒後に発火）
    func autoSave(_ publisher: Published<[ToDoItem]>.Publisher,
                  saveAction: @escaping ([ToDoItem]) -> Void) {
        publisher
            .dropFirst()
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink(receiveValue: saveAction)
            .store(in: &cancellables)
    }
    
    // 完了率100%検知 → コングラッツ表示
    func observeCompletionRate(_ publisher: Published<[ToDoItem]>.Publisher,
                               onComplete: @escaping () -> Void) {
        publisher
            .map { todos -> Double in
                guard !todos.isEmpty else { return 0 }
                let done = todos.filter { $0.isChecked }.count
                return (Double(done) / Double(todos.count)) * 100
            }
            .filter { $0 == 100 }
            .sink { _ in onComplete() }
            .store(in: &cancellables)
    }
    
    // 定期的に通知チェック（1分ごと）
    func scheduleNotification() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                NotificationManager.shared.checkIncompleteTasks()
            }
            .store(in: &cancellables)
    }
}
