//
//  StorageManager.swift
//  Snake
//
//  Created by Асиет Чеуж on 24.05.2024.
//

import SwiftUI

final class StorageManager
{
    static let shared = StorageManager()
    
    // Сохранение рекорда игрока
    @AppStorage(wrappedValue: 0, "highScore") private var highScore: Int
    
    private init() {}
    
    var getHighScore: Int{
        highScore
    }
    
    func setHightScoer(_ value: Int)
    {
        highScore = value
    }
}
