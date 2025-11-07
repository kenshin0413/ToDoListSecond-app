//
//  ChartView.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/04.
//

import SwiftUI
import Charts

struct ChartView: View {
    @EnvironmentObject var ListVM: ListViewModel
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("タスク統計")
                    .font(.title.bold())
                    .padding(.top, 20)
                
                Chart {
                    ForEach(ListVM.taskStats, id: \.category) { stat in
                        SectorMark(angle: .value("割合", stat.count),
                                   innerRadius: .ratio(0.6),
                                   outerRadius: .ratio(1.0)
                        )
                        .foregroundStyle(by: .value("カテゴリ", stat.category))
                    }
                }
                .frame(height: 250)
                .padding()
                
                VStack(spacing: 12) {
                    Text("総タスク数：\(ListVM.todoList.count)")
                    Text("完了タスク数：\(ListVM.completedCount)")
                    Text("未完了タスク数：\(ListVM.incompletedCount)")
                    Text("完了率：\(ListVM.completionRate, specifier: "%.1f")%")
                }
                .font(.headline)
                .padding(.bottom, 30)
            }
            .padding()
            .navigationTitle("統計")
            .navigationBarTitleDisplayMode(.inline)
            .alert("全タスク完了！", isPresented: $ListVM.showCongrats) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("すべてのタスクを完了しました！お疲れ様！")
            }
        }
    }
}

#Preview {
    ChartView()
}
