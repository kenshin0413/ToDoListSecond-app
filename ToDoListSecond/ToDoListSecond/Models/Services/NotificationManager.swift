//
//  NotificationManager.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/07.
//

import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("✅ 通知が許可されました")
            } else if let error = error {
                print("❌ 通知エラー: \(error.localizedDescription)")
            }
        }
    }
    
    func checkIncompleteTasks() {
        guard let viewModel = ListViewModelReference.shared?.viewModel else { return }
        let incomplete = viewModel.todoList.filter { !$0.isChecked }
        guard !incomplete.isEmpty else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "まだ終わってないタスクがあります！"
        content.body = "未完了のタスクは \(incomplete.count) 件です。"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        print("📣 通知を送信しました (\(incomplete.count)件未完了)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
