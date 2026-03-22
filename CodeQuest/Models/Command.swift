import Foundation

enum Command: Equatable, Identifiable {
    case moveForward
    case turnLeft
    case turnRight
    case repeatLoop(count: Int, commands: [Command])
    case ifWall(commands: [Command])

    var id: UUID {
        UUID()
    }

    var displayName: String {
        switch self {
        case .moveForward:
            return "Move Forward"
        case .turnLeft:
            return "Turn Left"
        case .turnRight:
            return "Turn Right"
        case .repeatLoop(let count, _):
            return "Repeat \(count)x"
        case .ifWall:
            return "If Wall"
        }
    }

    var iconName: String {
        switch self {
        case .moveForward:
            return "arrow.up"
        case .turnLeft:
            return "arrow.turn.up.left"
        case .turnRight:
            return "arrow.turn.up.right"
        case .repeatLoop:
            return "arrow.2.squarepath"
        case .ifWall:
            return "arrow.triangle.branch"
        }
    }

    var color: String {
        switch self {
        case .moveForward:
            return "blue"
        case .turnLeft:
            return "purple"
        case .turnRight:
            return "purple"
        case .repeatLoop:
            return "orange"
        case .ifWall:
            return "green"
        }
    }

    static func == (lhs: Command, rhs: Command) -> Bool {
        switch (lhs, rhs) {
        case (.moveForward, .moveForward):
            return true
        case (.turnLeft, .turnLeft):
            return true
        case (.turnRight, .turnRight):
            return true
        case (.repeatLoop(let count1, let commands1), .repeatLoop(let count2, let commands2)):
            return count1 == count2 && commands1 == commands2
        case (.ifWall(let commands1), .ifWall(let commands2)):
            return commands1 == commands2
        default:
            return false
        }
    }
}

struct ProgramCommand: Identifiable {
    let id = UUID()
    var command: Command
    var nestedCommands: [ProgramCommand] = []

    var isContainer: Bool {
        switch command {
        case .repeatLoop, .ifWall:
            return true
        default:
            return false
        }
    }
}
