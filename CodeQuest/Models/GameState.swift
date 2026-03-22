import Foundation
import SwiftUI

@MainActor
class GameState: ObservableObject {
    @Published var currentLevel: Level
    @Published var program: [ProgramCommand] = []
    @Published var robotPosition: GridPosition
    @Published var robotDirection: Direction
    @Published var isExecuting = false
    @Published var showVictory = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var completedLevels: Set<Int> = []
    @Published var currentStepIndex: Int?

    init(level: Level) {
        self.currentLevel = level
        self.robotPosition = level.startPosition
        self.robotDirection = level.startDirection
        loadProgress()
    }

    func addCommand(_ command: Command) {
        let programCommand = ProgramCommand(command: command)
        program.append(programCommand)
    }

    func removeCommand(at index: Int) {
        guard index < program.count else { return }
        program.remove(at: index)
    }

    func clearProgram() {
        program.removeAll()
    }

    func resetRobot() {
        robotPosition = currentLevel.startPosition
        robotDirection = currentLevel.startDirection
        showError = false
        showVictory = false
        errorMessage = ""
        currentStepIndex = nil
    }

    func executeProgram() async {
        guard !isExecuting else { return }

        isExecuting = true
        resetRobot()

        await Task.yield()

        let success = await executeCommands(program)

        if success && robotPosition == currentLevel.goalPosition {
            showVictory = true
            completedLevels.insert(currentLevel.id)
            saveProgress()
        }

        isExecuting = false
        currentStepIndex = nil
    }

    private func executeCommands(_ commands: [ProgramCommand]) async -> Bool {
        for (index, programCommand) in commands.enumerated() {
            currentStepIndex = index

            let success = await executeCommand(programCommand.command)
            if !success {
                return false
            }

            try? await Task.sleep(nanoseconds: 300_000_000)
        }
        return true
    }

    private func executeCommand(_ command: Command) async -> Bool {
        switch command {
        case .moveForward:
            let newPosition = robotDirection.forward(from: robotPosition)

            if newPosition.x < 0 || newPosition.x >= currentLevel.gridSize ||
               newPosition.y < 0 || newPosition.y >= currentLevel.gridSize {
                showError(message: "Out of bounds!")
                return false
            }

            if currentLevel.walls.contains(newPosition) {
                showError(message: "Hit a wall!")
                return false
            }

            robotPosition = newPosition

        case .turnLeft:
            robotDirection.turnLeft()

        case .turnRight:
            robotDirection.turnRight()

        case .repeatLoop(let count, let commands):
            for _ in 0..<count {
                let programCommands = commands.map { ProgramCommand(command: $0) }
                let success = await executeCommands(programCommands)
                if !success {
                    return false
                }
            }

        case .ifWall(let commands):
            let forwardPosition = robotDirection.forward(from: robotPosition)
            let isWall = forwardPosition.x < 0 || forwardPosition.x >= currentLevel.gridSize ||
                        forwardPosition.y < 0 || forwardPosition.y >= currentLevel.gridSize ||
                        currentLevel.walls.contains(forwardPosition)

            if isWall {
                let programCommands = commands.map { ProgramCommand(command: $0) }
                let success = await executeCommands(programCommands)
                if !success {
                    return false
                }
            }
        }

        return true
    }

    private func showError(message: String) {
        showError = true
        errorMessage = message
    }

    func loadLevel(_ level: Level) {
        currentLevel = level
        robotPosition = level.startPosition
        robotDirection = level.startDirection
        program.removeAll()
        showVictory = false
        showError = false
        errorMessage = ""
        currentStepIndex = nil
    }

    private func saveProgress() {
        let array = Array(completedLevels)
        UserDefaults.standard.set(array, forKey: "completedLevels")
    }

    private func loadProgress() {
        if let array = UserDefaults.standard.array(forKey: "completedLevels") as? [Int] {
            completedLevels = Set(array)
        }
    }
}
