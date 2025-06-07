//
//  AddTaskView.swift
//  tasmatim5
//
//  Created by MacBook on 08/05/25.
//

import SwiftUI
import SwiftData
import UserNotifications

struct AddTaskView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var details = ""
    @State private var deadline = Date()
    @State private var priority: Priority = .medium
    @State private var showErrorPopup = false
    @State private var hasAttemptedSave = false

    // Reminder States
    @State private var isReminderEnabled = false
    @State private var selectedReminder: ReminderOption? = .fiveMinutesBefore
    @State private var customReminderDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Info")) {
                    VStack(alignment: .leading) {
                        TextField("Title", text: $title)
                        if hasAttemptedSave && title.isEmpty {
                            Text("Required").foregroundColor(.red).font(.footnote)
                        }
                    }

                    VStack(alignment: .leading) {
                        TextField("Description", text: $details)
                        if hasAttemptedSave && details.isEmpty {
                            Text("Required").foregroundColor(.red).font(.footnote)
                        }
                    }

                    VStack(alignment: .leading) {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                        if hasAttemptedSave && deadline < Date().startOfDay {
                            Text("Deadline cannot be in the past").foregroundColor(.red).font(.footnote)
                        }
                    }

                    Picker("Priority", selection: $priority) {
                        ForEach(Priority.allCases) { p in
                            Text(p.rawValue.capitalized).tag(p)
                        }
                    }
                }

                // Reminder Section
                Section(header: Text("Reminder")) {
                    Toggle("Set Reminder", isOn: $isReminderEnabled)

                    if isReminderEnabled {
                        Picker("Reminder Time", selection: $selectedReminder) {
                            ForEach(ReminderOption.allCases, id: \.self) { option in
                                Text(option.description).tag(Optional(option))
                            }
                            Text("Custom").tag(ReminderOption?.none)
                        }

                        if selectedReminder == nil {
                            DatePicker("Custom Reminder", selection: $customReminderDate, displayedComponents: [.date, .hourAndMinute])
                        }
                    }
                }
            }
            .navigationTitle("Add Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        hasAttemptedSave = true
                        let isValid = !title.isEmpty && !details.isEmpty && deadline >= Date().startOfDay

                        if isValid {
                            let reminderDate: Date? = {
                                guard isReminderEnabled else { return nil }
                                if let option = selectedReminder {
                                    return option.calculateReminderDate(from: deadline)
                                } else {
                                    return customReminderDate
                                }
                            }()

                            let newTask = TaskItem(
                                title: title,
                                details: details,
                                deadline: deadline,
                                reminderDate: reminderDate,
                                priority: priority
                            )

                            context.insert(newTask)
                            scheduleNotification(for: newTask)
                            dismiss()
                        } else {
                            showErrorPopup = true
                        }
                    }
                }
            }
            .alert(isPresented: $showErrorPopup) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please fill in all the required fields."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    func scheduleNotification(for task: TaskItem) {
        guard let reminderDate = task.reminderDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: task.id.uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

// MARK: - ReminderOption Enum
enum ReminderOption: CaseIterable {
    case oneMinutesBefore, fiveMinutesBefore, tenMinutesBefore, oneHourBefore, oneDayBefore

    var description: String {
        switch self {
        case .oneMinutesBefore: return "1 minutes before"
        case .fiveMinutesBefore: return "5 minutes before"
        case .tenMinutesBefore:  return "10 minutes before"
        case .oneHourBefore: return "1 hour before"
        case .oneDayBefore: return "1 day before"
        }
    }

    func calculateReminderDate(from deadline: Date) -> Date {
        switch self {
        case .oneMinutesBefore: return deadline.addingTimeInterval(-1 * 60)
        case .fiveMinutesBefore: return deadline.addingTimeInterval(-5 * 60)
        case .tenMinutesBefore: return deadline.addingTimeInterval(-10 * 60)
        case .oneHourBefore: return deadline.addingTimeInterval(-60 * 60)
        case .oneDayBefore: return deadline.addingTimeInterval(-24 * 60 * 60)
        }
    }
}
