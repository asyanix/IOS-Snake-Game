//
//  ContentView.swift
//  Snake
//
//  Created by Асиет Чеуж on 23.05.2024.
//

import SwiftUI

struct GameView: View {
    @State private var viewModel = GameViewViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Text("Текущий счет: \(viewModel.score)")
                    .font(.headline)
                Spacer()
                Text("Рекорд: \(viewModel.highScore)")
                    .font(.headline)
            }
            CellView(viewModel: viewModel)
            // Считывание жестов
                .gesture(
                    DragGesture(minimumDistance: 0).onEnded{ value in
                        changeDirection(from: value)
                    }
                )
            
            Button(viewModel.buttonTitle, action: viewModel.buttonDidTapped)
                .padding()
        }
        .padding()
        
        .alert(
            "Игра окончена",
            isPresented: $viewModel.alertIsPresented,
            actions: {
                Button("Перезапустить", action: viewModel.buttonDidTapped)
                Button("Отменить") {}
            }, message: {
                Text("Ваш счет: \(viewModel.score), Рекорд: \(viewModel.highScore)")
            }
        )
    }
    
    // Определяем направление движения змейки по жестам
    private func changeDirection(from drag: DragGesture.Value)
    {
        let horizontal = drag.translation.width
        let vertical = drag.translation.height
        
        if abs(horizontal) > abs(vertical)
        {
            viewModel.changeDirection(to: horizontal > 0 ? .right: .left)
        }
        else
        {
            viewModel.changeDirection(to: vertical > 0 ? .down: .up)
        }
    }
    
}

#Preview {
    GameView()
}

struct CellView: View {
    let viewModel: GameViewViewModel
    var body: some View {
        // Игровое поле
        Grid(horizontalSpacing: 0, verticalSpacing: 0)
        {
            ForEach(0..<GridConfig.rowCount, id:\.self) { row in
                GridRow
                {
                    ForEach(0..<GridConfig.columnCount, id:\.self) { column in
                        var point: Point
                        {
                            Point(x: column, y: row)
                        }
                        
                        var cellColor: Color
                        {
                            if viewModel.snakeBody.contains(point){
                                .green
                            }
                            else if viewModel.apple == point
                            {
                                .red
                            }
                            else
                            {
                                .black
                            }
                        }
                        Rectangle()
                            .fill(cellColor)
                            .aspectRatio(contentMode: .fit)
                    }
                }
            }
        }
    }
}
