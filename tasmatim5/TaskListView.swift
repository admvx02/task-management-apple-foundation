//
//  TaskListView.swift
//  tasmatim5
//
//  Created by MacBook on 08/05/25.
//
import SwiftUI
import SwiftData
import WebKit

extension Priority {
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}


struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [TaskItem]
    @State private var searchText = ""
    @State private var selectedPriority: Priority? = nil
    @State private var showCompletionModal = false
    @State private var completedTaskTitle = ""
    @State private var selectedTaskForSheet: TaskItem?
    @State private var showingEdit = false
    
    var filteredTasks: [TaskItem] {
        tasks
            .filter { task in
                (searchText.isEmpty || task.title.localizedCaseInsensitiveContains(searchText) || task.details.localizedCaseInsensitiveContains(searchText)) &&
                (selectedPriority == nil || task.priority == selectedPriority!) &&
                !task.isCompleted
            }
            .sorted { (lhs: TaskItem, rhs: TaskItem) -> Bool in
                if lhs.priority.sortOrder == rhs.priority.sortOrder {
                    return lhs.deadline < rhs.deadline
                } else {
                    return lhs.priority.sortOrder < rhs.priority.sortOrder
                }
            }
    }


    var body: some View {
        NavigationStack {
            VStack {
                SearchBar(searchText: $searchText)

                Picker("Filter by Priority", selection: $selectedPriority) {
                    Text("All").tag(Priority?.none)
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized).tag(Priority?.some(priority))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding([.top, .horizontal])

                if filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 12) {
                                    Button(action: {
                                        toggleTaskCompletion(task)
                                    }) {
                                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.title2)
                                            .foregroundColor(task.isCompleted ? .green : .gray)
                                    }

                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(task.title)
                                                .font(.headline)
                                                .foregroundColor(priorityColor(task.priority))
                                            Spacer()
                                            Text(task.priority.rawValue.capitalized)
                                                .font(.caption)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(priorityColor(task.priority))
                                                .cornerRadius(8)
                                                .foregroundColor(.white)
                                        }

                                        if !task.details.isEmpty {
                                            Text(task.details)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }

                                        HStack(spacing: 8) {
                                            if task.deadline < Date() {
                                                Text("Overdue")
                                                    .font(.caption2)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.red.opacity(0.1))
                                                    .foregroundColor(.red)
                                                    .cornerRadius(8)
                                            } else {
                                                Text(timeRemaining(from: task.deadline))
                                                    .font(.caption2)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.1))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(8)
                                            }

                                            Spacer()

                                            Text("Due: \(formattedDate(task.deadline))")
                                                .font(.caption2)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.gray.opacity(0.1))
                                                .foregroundColor(.gray)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    selectedTaskForSheet = task
                                    showingEdit = false
                                } label: {
                                    Label("View", systemImage: "eye")
                                }
                                .tint(.blue)

                                Button {
                                    selectedTaskForSheet = task
                                    showingEdit = true
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)

                                Button(role: .destructive) {
                                    deleteTask(at: IndexSet(integer: filteredTasks.firstIndex(of: task)!))
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }

                    .listStyle(.plain)
                    .refreshable {}
                }
            }
//            .navigationTitle("Dashboard")
            .sheet(item: $selectedTaskForSheet) { task in
                if showingEdit {
                    TaskEditView(task: task)
                } else {
                    TaskDetailView(task: task)
                }
            }
            .sheet(isPresented: $showCompletionModal) {
                TaskCompletionModalView(taskTitle: completedTaskTitle) {
                    showCompletionModal = false
                }
            }
        }
    }

    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
//            GIFView(name: "Animation - 1746777412455")
//                .frame(height: 200)
//                .padding(.bottom, 10)
            Image("Visual Asset Tasma-02")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding()

            Text("No tasks available")
                .font(.title3)
                .foregroundColor(.gray)

            Text("Create a new task to get started.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .padding()
    }

    func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasks[index]
            context.delete(task)
        }
    }

    func toggleTaskCompletion(_ task: TaskItem) {
        task.isCompleted.toggle()
        try? context.save()
        if task.isCompleted {
            completedTaskTitle = task.title
            withAnimation {
                showCompletionModal = true
            }
        }
    }

    func timeRemaining(from date: Date) -> String {
        let remaining = Int(date.timeIntervalSinceNow)
        let hours = remaining / 3600
        let minutes = (remaining % 3600) / 60
        return "\(hours)h \(minutes)m left"
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        TextField("Search Tasks", text: $searchText)
            .padding(7)
            .padding(.horizontal, 25)
            .background(Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                    Spacer()
                }
            )
            .navigationTitle("Dashboard")
            .padding(.horizontal)
    }
}
