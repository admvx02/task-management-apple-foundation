//
//  TaskEditView.swift
//  tasmatim5
//
//  Created by MacBook on 12/05/25.
//
import SwiftUI
import SwiftData

struct TaskEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var task: TaskItem

    @State private var showValidationAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("TASK INFO")) {
                    TextField("Title", text: $task.title)
                        .autocapitalization(.sentences)

                    TextField("Details", text: $task.details)
                        .autocapitalization(.sentences)

                    DatePicker("Deadline", selection: $task.deadline, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)

                    DatePicker("Reminder", selection: Binding(
                        get: { task.reminderDate ?? Date() },
                        set: { task.reminderDate = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)

                    Picker("Priority", selection: $task.priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.rawValue.capitalized).tag(p)
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if task.title.trimmingCharacters(in: .whitespaces).isEmpty ||
                            task.details.trimmingCharacters(in: .whitespaces).isEmpty {
                            showValidationAlert = true
                        } else {
                            try? task.modelContext?.save()
                            dismiss()
                        }
                    }
                }
            }
            .alert("Please fill in both Title and Details.", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}


