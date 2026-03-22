import Foundation

struct GridPosition: Equatable, Hashable {
    var x: Int
    var y: Int
}

enum Direction: Int {
    case north = 0
    case east = 1
    case south = 2
    case west = 3

    mutating func turnLeft() {
        self = Direction(rawValue: (self.rawValue + 3) % 4)!
    }

    mutating func turnRight() {
        self = Direction(rawValue: (self.rawValue + 1) % 4)!
    }

    func forward(from position: GridPosition) -> GridPosition {
        switch self {
        case .north:
            return GridPosition(x: position.x, y: position.y - 1)
        case .east:
            return GridPosition(x: position.x + 1, y: position.y)
        case .south:
            return GridPosition(x: position.x, y: position.y + 1)
        case .west:
            return GridPosition(x: position.x - 1, y: position.y)
        }
    }
}

struct Level {
    let id: Int
    let name: String
    let description: String
    let gridSize: Int
    let walls: Set<GridPosition>
    let startPosition: GridPosition
    let startDirection: Direction
    let goalPosition: GridPosition
    let availableCommands: [Command]

    static let allLevels: [Level] = [
        Level(
            id: 1,
            name: "Hello World",
            description: "Navigate to the goal using basic commands",
            gridSize: 3,
            walls: [],
            startPosition: GridPosition(x: 0, y: 0),
            startDirection: .east,
            goalPosition: GridPosition(x: 2, y: 2),
            availableCommands: [.moveForward, .turnLeft, .turnRight]
        ),
        Level(
            id: 2,
            name: "Loop It",
            description: "Use repeat loops to traverse efficiently",
            gridSize: 5,
            walls: [],
            startPosition: GridPosition(x: 0, y: 2),
            startDirection: .east,
            goalPosition: GridPosition(x: 4, y: 2),
            availableCommands: [.moveForward, .turnLeft, .turnRight, .repeatLoop(count: 2, commands: [])]
        ),
        Level(
            id: 3,
            name: "Branch Out",
            description: "Navigate forks using conditional statements",
            gridSize: 5,
            walls: [
                GridPosition(x: 2, y: 0),
                GridPosition(x: 2, y: 1),
                GridPosition(x: 2, y: 3),
                GridPosition(x: 2, y: 4)
            ],
            startPosition: GridPosition(x: 0, y: 2),
            startDirection: .east,
            goalPosition: GridPosition(x: 4, y: 2),
            availableCommands: [.moveForward, .turnLeft, .turnRight, .repeatLoop(count: 2, commands: []), .ifWall(commands: [])]
        ),
        Level(
            id: 4,
            name: "Nested",
            description: "Combine loops and conditionals",
            gridSize: 6,
            walls: [
                GridPosition(x: 1, y: 0),
                GridPosition(x: 3, y: 0),
                GridPosition(x: 5, y: 0),
                GridPosition(x: 1, y: 2),
                GridPosition(x: 3, y: 2),
                GridPosition(x: 5, y: 2),
                GridPosition(x: 1, y: 4),
                GridPosition(x: 3, y: 4),
                GridPosition(x: 5, y: 4)
            ],
            startPosition: GridPosition(x: 0, y: 1),
            startDirection: .east,
            goalPosition: GridPosition(x: 4, y: 5),
            availableCommands: [.moveForward, .turnLeft, .turnRight, .repeatLoop(count: 2, commands: []), .ifWall(commands: [])]
        ),
        Level(
            id: 5,
            name: "Pathfinder",
            description: "Find your way through a complex maze",
            gridSize: 7,
            walls: [
                GridPosition(x: 1, y: 0), GridPosition(x: 1, y: 1), GridPosition(x: 1, y: 2),
                GridPosition(x: 3, y: 1), GridPosition(x: 3, y: 2), GridPosition(x: 3, y: 3),
                GridPosition(x: 5, y: 2), GridPosition(x: 5, y: 3), GridPosition(x: 5, y: 4),
                GridPosition(x: 0, y: 4), GridPosition(x: 2, y: 4), GridPosition(x: 4, y: 4),
                GridPosition(x: 2, y: 6)
            ],
            startPosition: GridPosition(x: 0, y: 0),
            startDirection: .south,
            goalPosition: GridPosition(x: 6, y: 6),
            availableCommands: [.moveForward, .turnLeft, .turnRight, .repeatLoop(count: 2, commands: []), .ifWall(commands: [])]
        )
    ]
}
