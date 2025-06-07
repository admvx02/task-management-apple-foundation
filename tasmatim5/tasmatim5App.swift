//
//  tasmatim5App.swift
//  tasmatim5
//
//  Created by MacBook on 08/05/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct tasmatim5: App {
    @AppStorage("hasOnboarded") var hasOnboarded = false

    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            if hasOnboarded {
                ContentView()
            } else {
                OnboardingView()
            }
        }
        .modelContainer(for: TaskItem.self)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }
}

