//
//  GameDelegate.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-05-02.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation

protocol GameDelegate: class {
    func messageSent(message: Int)
    
    func gameOver()
}
