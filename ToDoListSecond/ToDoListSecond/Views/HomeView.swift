//
//  HomeView.swift
//  ToDoListSecond
//
//  Created by miyamotokenshin on R 7/11/04.
//

import SwiftUI

struct HomeView: View {
    @State var selectedTab = 1
    @StateObject var ListVM = ListViewModel()
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ListView()
                    .environmentObject(ListVM)
            }
            .tabItem {
                Label("リスト", systemImage: "list.bullet")
            }
            .tag(1)
            
            NavigationStack {
                ChartView()
                    .environmentObject(ListVM)
            }
            .tabItem {
                Label("グラフ", systemImage: "chart.pie.fill")
            }
            .tag(2)
        }
    }
}

#Preview {
    HomeView()
}
