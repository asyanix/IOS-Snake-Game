//
//  GameViewViewModel.swift
//  Snake
//
//  Created by Асиет Чеуж on 23.05.2024.
//

import Foundation

// Состояние игры
enum GameState {
    case notStarted, playing, paused, gameOver
    
    var buttonTitle: String
    {
        switch self {
        case .notStarted:
            "Начать игру"
        case .playing:
            "Пауза"
        case .paused:
            "Продолжить"
        case .gameOver:
            "Заново"
        }
    }
}

enum Direction
{
    case up, down, left, right
}

// Конфигурация игрового поля
struct GridConfig
{
    static let columnCount = 10
    static let rowCount = 18
}

// Предоставление координат на игровом поле
struct Point: Equatable
{
    var x: Int
    var y: Int
    
    static var zero: Point
    {
        Point(x: 0, y: 0)
    }
}

// Модель представления для игры
@Observable
final class GameViewViewModel
{
    var snakeBody = [Point(x: 2, y: 2), Point(x: 2, y: 1), Point(x: 2, y: 0)]
    var apple = Point.zero
    
    var score = 0
    var alertIsPresented = false
    
    var highScore: Int
    {
        storageManager.getHighScore
    }
    
    var buttonTitle: String
    {
        currentState.buttonTitle
    }
    
    private var currentState: GameState = .notStarted
    private var currentDirection: Direction = .down
    
    private var timer: Timer?
    private let storageManager = StorageManager.shared
    
    func buttonDidTapped ()
    {
        switch currentState {
        case .notStarted:
            startGame()
        case .playing:
            pauseGame()
        case .paused:
            resumeGame()
        case .gameOver:
            startGame()
        }
    }
    
    func changeDirection(to newDirection: Direction)
    {
        // Запрещаем разворачиваться на 180 градусов
        switch (currentDirection, newDirection)
        {
            case (.up, .down), (.down, .up), (.left, .right), (.right, .left):
                break
            default:
                currentDirection = newDirection
        }
    }
    
    // Логика движения змеи
    private func moveSnake() {
        guard currentState != .gameOver else {return}
        
        let newHead = calculateNewHead()
        handleCollision(newHead: newHead)
    }
    
    private func handleCollision(newHead: Point)
    {
        // Съесть яблоко
        if newHead == apple
        {
            snakeBody.insert(newHead, at: 0)
            placeApple()
            score += 1
        }
        // Если столкновение с границами или с собственным телом -> конец игры
        else if newHead.x < 0 || newHead.y < 0 || newHead.x >= GridConfig.columnCount || newHead.y >= GridConfig.rowCount ||
                    snakeBody.dropFirst().contains(newHead) {
            endGame()
        }
        else
        {
            snakeBody.insert(newHead, at: 0)
            snakeBody.removeLast()
        }
    }
    
    // Управление змеей
    private func calculateNewHead() -> Point
    {
        var newHead = snakeBody.first ?? Point.zero
        
        switch currentDirection {
        case .up:
            newHead.y -= 1
        case .down:
            newHead.y += 1
        case .left:
            newHead.x -= 1
        case .right:
            newHead.x += 1
        }
        
        return newHead
    }
    
    // Старт игры
    private func startGame() {
        snakeBody = [Point(x: 2, y: 2), Point(x: 2, y: 1), Point(x: 2, y: 0)]
        placeApple()
        score = 0
        currentState = .playing
        setTimer()
    }
    
    // Конец игры
    private func endGame()
    {
        alertIsPresented.toggle()
        timer?.invalidate()
        currentState = .gameOver
        currentDirection = .down
        storageManager.setHightScoer(max(score, highScore))
    }
    
    // Пауза
    private func pauseGame()
    {
        timer?.invalidate()
        currentState = .paused
    }
    
    // Возобновление
    private func resumeGame()
    {
        setTimer()
        currentState = .playing
    }
    
    // Размещаем яблоко на поле
    private func placeApple()
    {
        repeat {
            apple = Point(
                x: Int.random(in: 0..<GridConfig.columnCount),
                y: Int.random(in: 0..<GridConfig.rowCount))
        }
        while snakeBody.contains(apple)
    }
    
    // Таймер
    private func setTimer() {
        timer = .scheduledTimer(withTimeInterval: 0.5, repeats: true)
        {
            [unowned self] _ in moveSnake()
        }
    }
}
