//
//  TaskCompletionModalView.swift
//  tasmatim5
//
//  Created by MacBook on 14/05/25.
//

import SwiftUI

struct TaskCompletionModalView: View {
    let taskTitle: String
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
//            GIFView(name: "Animation - 1747210709585")
//                .frame(height: 180)

            Text("Well Done!")
                .font(.title)
                .bold()
                .foregroundColor(.blue)

            Text("You've successfully completed:\(taskTitle)")
                .multilineTextAlignment(.center)
                .font(.body)
                .foregroundColor(.primary)

            Button("Continue") {
                onDismiss()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding()
        .presentationDetents([.fraction(0.50)])
    }
}

