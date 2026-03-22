import SwiftUI

struct ProgramView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Program")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(Color(hex: "00ff87"))

                Spacer()

                Button(action: {
                    gameState.clearProgram()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(gameState.isExecuting || gameState.program.isEmpty)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if gameState.program.isEmpty {
                        Text("Click commands to add them")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(Array(gameState.program.enumerated()), id: \.element.id) { index, programCommand in
                            ProgramCommandRow(
                                programCommand: programCommand,
                                index: index,
                                isCurrentStep: gameState.currentStepIndex == index,
                                onDelete: {
                                    gameState.removeCommand(at: index)
                                }
                            )
                            .disabled(gameState.isExecuting)
                        }
                    }
                }
            }

            Spacer()

            HStack {
                Button(action: {
                    gameState.resetRobot()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .font(.system(size: 14, design: .monospaced))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(hex: "1a1a2e"))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(gameState.isExecuting)

                Spacer()

                Button(action: {
                    Task {
                        await gameState.executeProgram()
                    }
                }) {
                    HStack {
                        Image(systemName: gameState.isExecuting ? "stop.fill" : "play.fill")
                        Text(gameState.isExecuting ? "Running..." : "Run")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(gameState.isExecuting ? Color.orange : Color(hex: "00ff87"))
                    .foregroundColor(Color(hex: "1a1a2e"))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(gameState.program.isEmpty)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color(hex: "0f0f1e"))
    }
}

struct ProgramCommandRow: View {
    let programCommand: ProgramCommand
    let index: Int
    let isCurrentStep: Bool
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Text("\(index + 1).")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
                .frame(width: 30, alignment: .trailing)

            Image(systemName: programCommand.command.iconName)
                .foregroundColor(colorForCommand(programCommand.command))
                .frame(width: 20)

            Text(commandDescription)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.7))
                    .imageScale(.small)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(8)
        .background(isCurrentStep ? Color(hex: "00ff87").opacity(0.2) : Color(hex: "1a1a2e"))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isCurrentStep ? Color(hex: "00ff87") : Color.clear, lineWidth: 2)
        )
    }

    private var commandDescription: String {
        switch programCommand.command {
        case .repeatLoop(let count, _):
            return "Repeat \(count)x"
        default:
            return programCommand.command.displayName
        }
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
