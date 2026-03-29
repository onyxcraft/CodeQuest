import SwiftUI

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let icon: String
    let color: Color
    let requirement: Int
    let current: Int

    var isUnlocked: Bool { current >= requirement }
    var progress: Double { min(Double(current) / Double(requirement), 1.0) }
}

struct AchievementsView: View {
    @AppStorage("completedLevels") private var completedLevelsData: Data = Data()
    @AppStorage("totalMoves") private var totalMoves = 0
    @AppStorage("totalAttempts") private var totalAttempts = 0
    @AppStorage("bestStreak") private var bestStreak = 0

    private var completedCount: Int {
        (try? JSONDecoder().decode([Int].self, from: completedLevelsData))?.count ?? 0
    }

    private var achievements: [Achievement] {
        [
            Achievement(title: "First Steps", description: "Complete your first level", icon: "figure.walk", color: .green, requirement: 1, current: completedCount),
            Achievement(title: "Getting Started", description: "Complete 5 levels", icon: "star.fill", color: .yellow, requirement: 5, current: completedCount),
            Achievement(title: "Puzzle Master", description: "Complete 15 levels", icon: "trophy.fill", color: .orange, requirement: 15, current: completedCount),
            Achievement(title: "Algorithm Expert", description: "Complete 30 levels", icon: "crown.fill", color: .purple, requirement: 30, current: completedCount),
            Achievement(title: "Persistent", description: "Make 100 attempts", icon: "arrow.counterclockwise", color: .blue, requirement: 100, current: totalAttempts),
            Achievement(title: "Efficient Coder", description: "Use fewer than 500 total moves", icon: "bolt.fill", color: .mint, requirement: 1, current: totalMoves < 500 && completedCount > 0 ? 1 : 0),
            Achievement(title: "On Fire", description: "Complete 3 levels in a row", icon: "flame.fill", color: .red, requirement: 3, current: bestStreak),
            Achievement(title: "Streak Master", description: "Complete 10 levels in a row", icon: "flame.circle.fill", color: .red, requirement: 10, current: bestStreak),
        ]
    }

    private var unlockedCount: Int { achievements.filter(\.isUnlocked).count }

    var body: some View {
        NavigationView {
            ScrollView {
                // Summary
                VStack(spacing: 4) {
                    Text("\(unlockedCount)/\(achievements.count)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    Text("Achievements Unlocked")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    ProgressView(value: Double(unlockedCount), total: Double(achievements.count))
                        .tint(.orange)
                        .padding(.horizontal, 40)
                        .padding(.top, 8)
                }
                .padding(.vertical, 20)

                // Achievement list
                LazyVStack(spacing: 12) {
                    ForEach(achievements) { achievement in
                        achievementRow(achievement)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Achievements")
        }
    }

    private func achievementRow(_ achievement: Achievement) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? achievement.color.opacity(0.15) : Color(.systemGray5))
                    .frame(width: 50, height: 50)
                Image(systemName: achievement.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(achievement.isUnlocked ? achievement.color : .gray)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? .primary : .secondary)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress)
                        .tint(achievement.color)
                }
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 22))
            }
        }
        .padding(14)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    AchievementsView()
}
