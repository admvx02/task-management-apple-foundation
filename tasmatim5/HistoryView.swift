//
//  HistoryView.swift
//  tasmatim5
//
//  Created by MacBook on 08/05/25.
//
import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query private var tasks: [TaskItem]
    
    //    @AppStorage("lastUnlockedBadgeTitle") private var lastUnlockedBadgeTitle: String = ""
    @State private var selectedFilter: Priority? = nil
    @State private var streakCount: Int = 0
    @State private var showBadgeAlert = false
    @State private var unlockedBadge: Badge? = nil
    
    
    
    var completedTasks: [TaskItem] {
        let filtered = tasks.filter { $0.isCompleted }
        if let filter = selectedFilter {
            return filtered.filter { $0.priority == filter }
        }
        return filtered
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                // 🎯 Complete Streak Card
                VStack(alignment: .leading, spacing: 12) {
                    StreakProgressView(completedCount: streakCount)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal)
                .padding(.top)
                
                // 📌 Segmented Picker for Filtering
                Picker("Priority Filter", selection: $selectedFilter) {
                    Text("All").tag(Priority?.none)
                    ForEach(Priority.allCases, id: \.self) { priority in
                        Text(priority.rawValue.capitalized).tag(Optional(priority))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 📋 Task List or Empty State
                if completedTasks.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(completedTasks) { task in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(task.title)
                                                .font(.headline)
                                            
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
                                            Text("Deadline: \(formattedDate(task.deadline))")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            
                                            if Date() > task.deadline {
                                                Text("Overdue")
                                                    .font(.caption2)
                                                    .foregroundColor(.red)
                                                    .padding(4)
                                                    .background(Color.red.opacity(0.1))
                                                    .cornerRadius(4)
                                            } else {
                                                Text("On Time")
                                                    .font(.caption2)
                                                    .foregroundColor(.green)
                                                    .padding(4)
                                                    .background(Color.green.opacity(0.1))
                                                    .cornerRadius(4)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete(perform: deleteTask)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        calculateCompleteStreak()
                    }
                }
            }
            .navigationTitle("History")
            .onAppear {
                calculateCompleteStreak()
            }
        }
    }
    
    
    func deleteTask(at offsets: IndexSet) {
        for index in offsets {
            let task = completedTasks[index]
            context.delete(task)
        }
        calculateCompleteStreak()
    }
    
    func deleteAllTasks() {
        for task in completedTasks {
            context.delete(task)
        }
        calculateCompleteStreak()
    }
    
    func calculateCompleteStreak() {
        streakCount = tasks.filter { $0.isCompleted }.count
    }
    
    func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image("Visual Asset Tasma-03")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .padding(.top, 16)
            
            VStack(spacing: 8) {
                Text("No Completed Tasks")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Tasks you complete will appear here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.bottom, 60)
    }
}


struct StreakProgressView: View {
    let completedCount: Int
    let milestones: [Int] = [3, 5, 10, 15, 20, 25, 30]
    
    var lastReachedMilestone: Int? {
        milestones.filter { completedCount >= $0 }.last
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(milestones, id: \.self) { milestone in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(completedCount >= milestone ? Color.orange : Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Group {
                                    if lastReachedMilestone == milestone {
                                        Image(systemName: "flame.fill")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16))
                                    } else {
                                        Text("\(milestone)")
                                            .font(.caption2)
                                            .foregroundColor(completedCount >= milestone ? .white : .gray)
                                    }
                                }
                            )
                        
                        if completedCount >= milestone {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            
            Text(message)
                .font(.footnote)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
            
            BadgeView(streakCount: completedCount)
                .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 4)
    }
    
    var message: String {
        if completedCount >= milestones.last! {
            return "🔥 Max streak reached! Keep it up!"
        } else if completedCount >= 3 {
            return "🔥 You're on fire! Keep going!"
        } else {
            return "Complete more tasks to reach your streak!"
        }
    }
}
