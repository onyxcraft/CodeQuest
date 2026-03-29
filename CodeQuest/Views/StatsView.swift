import SwiftUI

struct StatsView: View {
    @AppStorage("completedLevels") private var completedLevelsData: Data = Data()
    @AppStorage("totalMoves") private var totalMoves = 0
    @AppStorage("totalAttempts") private var totalAttempts = 0
    @AppStorage("totalPlayTime") private var totalPlayTime: Double = 0
    @AppStorage("bestStreak") private var bestStreak = 0

    private var completedCount: Int {
        (try? JSONDecoder().decode([Int].self, from: completedLevelsData))?.count ?? 0
    }

    private var formattedPlayTime: String {
        let hours = Int(totalPlayTime) / 3600
        let minutes = (Int(totalPlayTime) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    statCard(title: "Levels Cleared", value: "\(completedCount)", icon: "checkmark.circle.fill", color: .green)
                    statCard(title: "Total Moves", value: "\(totalMoves)", icon: "arrow.up.arrow.down", color: .blue)
                    statCard(title: "Attempts", value: "\(totalAttempts)", icon: "arrow.counterclockwise", color: .orange)
                    statCard(title: "Play Time", value: formattedPlayTime, icon: "clock.fill", color: .purple)
                    statCard(title: "Best Streak", value: "\(bestStreak)", icon: "flame.fill", color: .red)
                    statCard(title: "Efficiency", value: totalAttempts > 0 ? "\(Int(Double(completedCount) / Double(totalAttempts) * 100))%" : "—", icon: "chart.bar.fill", color: .mint)
                }
                .padding()

                // Tips section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Algorithm Tips")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(tips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                                .font(.system(size: 14))
                                .frame(width: 24, height: 24)
                            Text(tip)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var tips: [String] {
        [
            "Break complex paths into smaller repeatable patterns",
            "Loops save moves — look for repetition in your solution",
            "Plan your route before placing commands",
            "The fewest moves often means the most elegant algorithm",
            "Conditionals let your robot adapt to obstacles"
        ]
    }
}

#Preview {
    StatsView()
}
