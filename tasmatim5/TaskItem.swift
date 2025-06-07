//
//  TaskItem.swift
//  tasmatim5
//
//  Created by MacBook on 08/05/25.
//
import Foundation
import SwiftData

@Model
class TaskItem: Identifiable {
    var id = UUID()
    var title: String
    var details: String
    var deadline: Date
    var reminderDate: Date?
    var priority: Priority
    var isCompleted: Bool = false
    

    init(title: String, details: String, deadline: Date, reminderDate: Date?, priority: Priority) {
        self.title = title
        self.details = details
        self.deadline = deadline
        self.reminderDate = reminderDate
        self.priority = priority
    }
}

enum Priority: String, Codable, CaseIterable, Identifiable {
    var id: String { rawValue }
    case low, medium, high
}
