//
//  TaskItem.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/01.
//

import Foundation

struct ToDoItem: Identifiable, Codable {
    var id = UUID()
    var isChecked: Bool
    var task: String
    var memo: String = ""
    var createdAt: Date = Date()
}
