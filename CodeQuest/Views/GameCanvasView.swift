import SwiftUI
import SpriteKit

struct GameCanvasView: View {
    @ObservedObject var gameState: GameState

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteView(scene: createScene(size: geometry.size))
                    .ignoresSafeArea()

                if gameState.showError {
                    ErrorOverlay(message: gameState.errorMessage)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .background(Color(hex: "1a1a2e"))
    }

    private func createScene(size: CGSize) -> SKScene {
        let scene = GameScene(gameState: gameState)
        scene.size = size
        scene.scaleMode = .aspectFit
        return scene
    }
}

class GameScene: SKScene {
    var gameState: GameState
    var gridNodes: [[SKShapeNode]] = []
    var wallNodes: [SKShapeNode] = []
    var robotNode: SKSpriteNode!
    var goalNode: SKShapeNode!
    var cellSize: CGFloat = 0

    init(gameState: GameState) {
        self.gameState = gameState
        super.init(size: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(Color(hex: "1a1a2e"))
        setupGrid()
        setupWalls()
        setupRobot()
        setupGoal()

        observeGameState()
    }

    private func setupGrid() {
        gridNodes.removeAll()
        removeAllChildren()

        let gridSize = gameState.currentLevel.gridSize
        let availableSize = min(size.width, size.height) * 0.8
        cellSize = availableSize / CGFloat(gridSize)

        let gridWidth = cellSize * CGFloat(gridSize)
        let gridHeight = cellSize * CGFloat(gridSize)
        let startX = (size.width - gridWidth) / 2
        let startY = (size.height - gridHeight) / 2

        for y in 0..<gridSize {
            var row: [SKShapeNode] = []
            for x in 0..<gridSize {
                let rect = CGRect(
                    x: startX + CGFloat(x) * cellSize,
                    y: startY + CGFloat(y) * cellSize,
                    width: cellSize,
                    height: cellSize
                )
                let cell = SKShapeNode(rect: rect)
                cell.strokeColor = SKColor(Color(hex: "00ff87").opacity(0.2))
                cell.lineWidth = 1
                cell.fillColor = .clear
                addChild(cell)
                row.append(cell)
            }
            gridNodes.append(row)
        }
    }

    private func setupWalls() {
        wallNodes.removeAll()
        let gridSize = gameState.currentLevel.gridSize
        let gridWidth = cellSize * CGFloat(gridSize)
        let gridHeight = cellSize * CGFloat(gridSize)
        let startX = (size.width - gridWidth) / 2
        let startY = (size.height - gridHeight) / 2

        for wall in gameState.currentLevel.walls {
            let rect = CGRect(
                x: startX + CGFloat(wall.x) * cellSize,
                y: startY + CGFloat(gridSize - wall.y - 1) * cellSize,
                width: cellSize,
                height: cellSize
            )
            let wallNode = SKShapeNode(rect: rect)
            wallNode.fillColor = SKColor(Color(hex: "3a4f7a"))
            wallNode.strokeColor = SKColor(Color(hex: "4a6fa5"))
            wallNode.lineWidth = 2
            addChild(wallNode)
            wallNodes.append(wallNode)
        }
    }

    private func setupRobot() {
        let robotSize = cellSize * 0.6
        robotNode = SKSpriteNode(color: .clear, size: CGSize(width: robotSize, height: robotSize))

        let label = SKLabelNode(text: "🤖")
        label.fontSize = robotSize * 0.8
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        robotNode.addChild(label)

        addChild(robotNode)
        updateRobotPosition()
    }

    private func setupGoal() {
        let gridSize = gameState.currentLevel.gridSize
        let gridWidth = cellSize * CGFloat(gridSize)
        let gridHeight = cellSize * CGFloat(gridSize)
        let startX = (size.width - gridWidth) / 2
        let startY = (size.height - gridHeight) / 2

        let goal = gameState.currentLevel.goalPosition
        let goalSize = cellSize * 0.5

        goalNode = SKShapeNode(circleOfRadius: goalSize / 2)
        goalNode.position = CGPoint(
            x: startX + CGFloat(goal.x) * cellSize + cellSize / 2,
            y: startY + CGFloat(gridSize - goal.y - 1) * cellSize + cellSize / 2
        )
        goalNode.fillColor = SKColor(Color.yellow)
        goalNode.strokeColor = SKColor(Color.yellow.opacity(0.5))
        goalNode.lineWidth = 3

        addChild(goalNode)

        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.5),
            SKAction.scale(to: 1.0, duration: 0.5)
        ])
        goalNode.run(SKAction.repeatForever(pulse))
    }

    private func updateRobotPosition() {
        let gridSize = gameState.currentLevel.gridSize
        let gridWidth = cellSize * CGFloat(gridSize)
        let gridHeight = cellSize * CGFloat(gridSize)
        let startX = (size.width - gridWidth) / 2
        let startY = (size.height - gridHeight) / 2

        let targetPosition = CGPoint(
            x: startX + CGFloat(gameState.robotPosition.x) * cellSize + cellSize / 2,
            y: startY + CGFloat(gridSize - gameState.robotPosition.y - 1) * cellSize + cellSize / 2
        )

        let angle: CGFloat = {
            switch gameState.robotDirection {
            case .north: return 0
            case .east: return -.pi / 2
            case .south: return .pi
            case .west: return .pi / 2
            }
        }()

        robotNode.run(SKAction.move(to: targetPosition, duration: 0.2))
        robotNode.run(SKAction.rotate(toAngle: angle, duration: 0.2))
    }

    private func observeGameState() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateRobotPosition()

                if self.gameState.showError {
                    self.shakeRobot()
                }
            }
        }
    }

    private func shakeRobot() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -5, y: 0, duration: 0.05)
        ])
        robotNode.run(shake)
    }
}

struct ErrorOverlay: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.yellow)
                Text(message)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.red.opacity(0.9))
            .cornerRadius(8)
            .padding(.bottom, 40)
        }
    }
}
