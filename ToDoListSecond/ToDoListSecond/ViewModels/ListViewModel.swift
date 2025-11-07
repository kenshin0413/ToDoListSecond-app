//
//  HomeViewModel.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/01.
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

class ListViewModel: NSObject,ObservableObject,  UNUserNotificationCenterDelegate {
    @Published var showAddTask = false
    @Published var addTask = ""
    // パブリッシャー　値の変化を配信する
    @Published var todoList: [ToDoItem] = [ToDoItem(isChecked: false, task: "買い物に行く"), ToDoItem(isChecked: false, task: "ジムに行く"), ToDoItem(isChecked: false, task: "塾に行く")]
    @Published var deleteOffsets: IndexSet?
    @Published var showDeleteAlert = false
    @Published var sortOption: SortOption = .new
    @Published var showCongrats = false
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        loadTask()
        setupCompletionRateMonitor()
        setupAutoSave()
        requestNotificationPermission()
        setupNotificationScheduler()
        UNUserNotificationCenter.current().delegate = self
    }
    
    let taskkey = "todoList"
    
    func setupAutoSave() {
        $todoList
            .dropFirst()
        // 1秒間入力が止まったら実行
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveTasks()
            }
            .store(in: &cancellables)
    }
    
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
            sortTask()
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
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        todoList.move(fromOffsets: source, toOffset: destination)
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
    // Chart
    
    var completedCount: Int {
        todoList.filter { $0.isChecked }.count
    }
    
    var incompletedCount: Int {
        todoList.filter { !$0.isChecked }.count
    }
    
    var completionRate: Double {
        guard !todoList.isEmpty else { return 0 }
        return (Double(completedCount) / Double(todoList.count)) * 100
    }
    
    var taskStats: [TaskStat] {
        [TaskStat(category: "未完了", count: incompletedCount), TaskStat(category: "完了", count: completedCount)]
    }
    
    private func setupCompletionRateMonitor() {
        // $todoListと書くとそのPublisherにアクセスできる
        $todoList
        // オペレーター 値を加工したり、条件で通したり、複数を組み合わせたりする
            .map { todos -> Double in
                //空配列なら0%を返す
                guard !todos.isEmpty else { return 0 }
                // 完了済のタスクを数える
                let completed = todos.filter { $0.isChecked }.count
                // 完了率を計算
                return (Double(completed) / Double(todos.count)) * 100
            }
        // 完了率が100なら.sinkに通す
            .filter { $0 == 100 }
        // サブスクライバー 変化を受け取って処理する
            .sink { [weak self] _ in
                print("すべてのタスク完了!")
                self?.showCongrats = true
            }
            .store(in: &cancellables)
    }
    // 通知
    
    // 通知の許可を求めるだけ
    func requestNotificationPermission() {
        // iOSに通知を出していいか確認するAPI
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { succes, error in
            if succes {
                print("通知許可されました。")
            } else if let error = error {
                print("通知許可エラー：\(error.localizedDescription)。")
            }
        }
    }
    //######################
    func setupNotificationScheduler() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.checkIncompleteTasks()
            }
            .store(in: &cancellables)
    }
    
    func checkIncompleteTasks() {
        let incomplete = todoList.filter { !$0.isChecked }
        guard !incomplete.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "まだ終わってないタスクがあります！"
        content.body = "現在、未完了のタスクは\(incomplete.count)件です。"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("通知を送信しました。")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
