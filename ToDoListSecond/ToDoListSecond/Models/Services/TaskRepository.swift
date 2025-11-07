//
//  TaskRepository.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/07.
//

import Foundation

final class TaskRepository {
    private let key = "todoList"
    
    func save(_ list: [ToDoItem]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
            print("✅ タスクを保存しました (\(list.count)件)")
        }
    }
    
    func load() -> [ToDoItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ToDoItem].self, from: data)
        else {
            print("⚠️ 保存データなし。初期値を使用します。")
            return []
        }
        print("✅ タスクを読み込みました (\(decoded.count)件)")
        return decoded
    }
}
