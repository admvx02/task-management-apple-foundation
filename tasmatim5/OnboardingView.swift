//
//  OnboardingView.swift
//  tasmatim5
//
//  Created by MacBook on 08/05/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasOnboarded") var hasOnboarded = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

//              GIFView(name: "Animation - 1746775637467")
//                    .frame(height: 200)
//                    .padding()
            
            Image("Visual Asset Tasma-01")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .padding()

            Text("Welcome to Tasma")
                .font(.system(size: 30, weight: .heavy, design: .default))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Stay organized and productive with smart reminders, priority levels, and a clean interface.")
                .font(.system(size: 17, weight: .medium, design: .default))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
            
            Button(action: {
                hasOnboarded = true
            }) {
                HStack {
                    Spacer()
                    Text("Get Started")
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.right")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

