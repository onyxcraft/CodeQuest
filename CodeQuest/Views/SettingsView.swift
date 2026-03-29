import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticEnabled") private var hapticEnabled = true
    @AppStorage("showGridLines") private var showGridLines = true
    @AppStorage("animationSpeed") private var animationSpeed = 1.0
    @AppStorage("colorScheme") private var selectedScheme = "system"

    var body: some View {
        NavigationView {
            Form {
                Section("Gameplay") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Haptic Feedback", isOn: $hapticEnabled)
                    Toggle("Show Grid Lines", isOn: $showGridLines)

                    VStack(alignment: .leading) {
                        Text("Animation Speed")
                        HStack {
                            Text("0.5x")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Slider(value: $animationSpeed, in: 0.5...3.0, step: 0.5)
                            Text("\(animationSpeed, specifier: "%.1f")x")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Appearance") {
                    Picker("Color Scheme", selection: $selectedScheme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                }

                Section("Data") {
                    Button("Reset All Progress", role: .destructive) {
                        UserDefaults.standard.removeObject(forKey: "completedLevels")
                        UserDefaults.standard.removeObject(forKey: "levelStars")
                        UserDefaults.standard.removeObject(forKey: "totalMoves")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
