//
//  Game.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-17.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation
import UIKit

protocol Game {
    var width: Double {get}
    var height: Double {get}
    var playing: Bool {get set}
    var delegate: GameDelegate? {get set}
        
    func draw(_ rect: CGRect)
    
    func onTouch(x: Double, y: Double)
    
    func send(message: Int)
    
    func isOver()
    
    func receive(message: Int)
    
    //func onTouch(x: Double, y: Double, gesture: UIGestureRecognizer)
}
