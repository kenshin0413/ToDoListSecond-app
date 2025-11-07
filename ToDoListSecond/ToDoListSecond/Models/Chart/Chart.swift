//
//  Chart.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/04.
//
import Foundation

struct TaskStat: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
}
