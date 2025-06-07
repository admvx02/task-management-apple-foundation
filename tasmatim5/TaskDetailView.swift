//
//  TaskDetailView.swift
//  tasmatim5
//
//  Created by MacBook on 12/05/25.
//

import SwiftUI

struct TaskDetailView: View {
    let task: TaskItem
    @Environment(\.dismiss) private var dismiss
    @State private var showEditView = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Back Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("Back")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.bottom)

                VStack(alignment: .leading, spacing: 8) {
                    Text(task.title)
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)

                    Text(task.details)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(16)
                .shadow(radius: 3)

                detailRow(systemIcon: "calendar", label: "Deadline", value: formattedDate(task.deadline))
                detailRow(systemIcon: "flag", label: "Priority", value: task.priority.rawValue.capitalized, color: priorityColor(task.priority))

                if let reminder = task.reminderDate {
                    detailRow(systemIcon: "bell", label: "Reminder", value: formattedDate(reminder))
                }

        
                Button {
                    showEditView = true
                } label: {
                    Label("Edit Task", systemImage: "pencil")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top)

            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditView) {
            TaskEditView(task: task)
        }
    }

    @ViewBuilder
    func detailRow(systemIcon: String, label: String, value: String, color: Color = .primary) -> some View {
        HStack {
            Image(systemName: systemIcon)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .foregroundColor(color)
                    .font(.body)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
