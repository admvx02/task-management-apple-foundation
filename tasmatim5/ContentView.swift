//
//  ContentView.swift
//  tasmatim5
//
//  Created by MacBook on 08/05/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isAddTaskPresented = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
         
            TaskListView()
                .tabItem {
                    Label("Dashboard", systemImage: "list.bullet")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock")
                }
                .tag(1)
        }
        .overlay(
            Group {
                if selectedTab == 0 {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                isAddTaskPresented.toggle()
                            }) {
                                Text("Add Task")
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                }
            },
            alignment: .topTrailing
        )
        .sheet(isPresented: $isAddTaskPresented) {
            AddTaskView()
        }
    }
}

