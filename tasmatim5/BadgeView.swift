//
//  BadgeView.swift
//  tasmatim5
//
//  Created by MacBook on 10/05/25.
//

import SwiftUI

struct BadgeView: View {
    let streakCount: Int

    @State private var newlyUnlockedBadge: Badge?
    @AppStorage("shownBadgeTitles") private var shownBadgeTitles: String = ""

    var unlockedBadges: [Badge] {
        Badge.allCases.filter { streakCount >= $0.requirement }
    }

    var lockedBadges: [Badge] {
        Badge.allCases.filter { streakCount < $0.requirement }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🎖️ Badges")
                .font(.headline)
                .padding(.leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(unlockedBadges) { badge in
                        VStack {
                            Image(badge.iconImageName)
                                .resizable()
                                .frame(width: 25, height: 25)
                            Text(badge.title)
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }

                    ForEach(lockedBadges) { badge in
                        VStack {
                            Image(systemName: "lock.fill")
                                .resizable()
                                .frame(width: 25, height: 30)
                                .foregroundColor(.gray)
                            Text(badge.title)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            checkNewlyUnlockedBadge()
        }
        .sheet(item: $newlyUnlockedBadge) { badge in
            VStack(spacing: 24) {
                Image(badge.iconImageName)
                    .resizable()
                    .frame(width: 60, height: 60)

                Text("🎉 Congratulation!")
                    .font(.title)
                    .bold()

                Text("You have successfully obtained a new badge:\n**\(badge.title)**!\n\n🔥 Keep up the spirit and earn the next badge!")
                    .multilineTextAlignment(.center)

                Button("Continue") {
                    addShownBadgeTitle(badge.title)
                    newlyUnlockedBadge = nil
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
            .presentationDetents([.fraction(0.4)])
        }
    }

    private func checkNewlyUnlockedBadge() {
        let shownBadges = shownBadgeTitles.components(separatedBy: ",")
        if let newBadge = Badge.allCases
            .filter({ streakCount == $0.requirement && !shownBadges.contains($0.title) })
            .first {
            newlyUnlockedBadge = newBadge
        }
    }

    private func addShownBadgeTitle(_ title: String) {
        var titles = shownBadgeTitles.components(separatedBy: ",").filter { !$0.isEmpty }
        titles.append(title)
        shownBadgeTitles = titles.joined(separator: ",")
    }
}

struct Badge: Identifiable, CaseIterable, Equatable {
    var id: String { title }

    let title: String
    let requirement: Int
    let iconImageName: String

    static let allCases: [Badge] = [
        Badge(title: "Novice", requirement: 3, iconImageName: "Visual Asset Tasma-04"),
        Badge(title: "Beginner", requirement: 5, iconImageName: "Visual Asset Tasma-05"),
        Badge(title: "Intermediate", requirement: 10, iconImageName: "Visual Asset Tasma-06"),
        Badge(title: "Advanced I", requirement: 15, iconImageName: "Visual Asset Tasma-07"),
        Badge(title: "Advanced II", requirement: 20, iconImageName: "Visual Asset Tasma-08"),
        Badge(title: "Advanced III", requirement: 25, iconImageName: "Visual Asset Tasma-09"),
        Badge(title: "Master I", requirement: 30, iconImageName: "badge_master1"),
        Badge(title: "Master II", requirement: 40, iconImageName: "badge_master2"),
        Badge(title: "Master III", requirement: 50, iconImageName: "badge_master3")
    ]
}
