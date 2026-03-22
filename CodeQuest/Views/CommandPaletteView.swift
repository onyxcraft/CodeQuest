import SwiftUI

struct CommandPaletteView: View {
    @ObservedObject var gameState: GameState
    @State private var showRepeatPicker = false
    @State private var repeatCount = 2

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Commands")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: "00ff87"))

            VStack(spacing: 8) {
                ForEach(gameState.currentLevel.availableCommands, id: \.displayName) { command in
                    commandButton(for: command)
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 200)
        .background(Color(hex: "0f0f1e"))
        .sheet(isPresented: $showRepeatPicker) {
            RepeatPickerView(count: $repeatCount, onConfirm: {
                let repeatCommand = Command.repeatLoop(count: repeatCount, commands: [])
                gameState.addCommand(repeatCommand)
                showRepeatPicker = false
            })
        }
    }

    @ViewBuilder
    private func commandButton(for command: Command) -> some View {
        Button(action: {
            switch command {
            case .repeatLoop:
                showRepeatPicker = true
            case .ifWall:
                let ifCommand = Command.ifWall(commands: [])
                gameState.addCommand(ifCommand)
            default:
                gameState.addCommand(command)
            }
        }) {
            HStack {
                Image(systemName: command.iconName)
                    .foregroundColor(colorForCommand(command))
                    .frame(width: 20)
                Text(command.displayName)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(10)
            .background(Color(hex: "1a1a2e"))
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(gameState.isExecuting)
    }

    private func colorForCommand(_ command: Command) -> Color {
        switch command.color {
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "green": return Color(hex: "00ff87")
        default: return .white
        }
    }
}

struct RepeatPickerView: View {
    @Binding var count: Int
    let onConfirm: () -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Repeat Count")
                .font(.system(size: 18, weight: .bold, design: .monospaced))

            Picker("Count", selection: $count) {
                ForEach(2..<11) { n in
                    Text("\(n)").tag(n)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)

            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Button("Add") {
                    onConfirm()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 250, height: 220)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
