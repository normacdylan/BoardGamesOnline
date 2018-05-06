//
//  GameDrawer.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-26.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation
import UIKit

class GameDrawer: UIView {
   var game: Game?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGestureRecognizers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startGame() {
        guard var currentGame = game else {return}
        currentGame.playing = true
    }
    
    override func draw(_ rect: CGRect) {
        if let game = game {
            game.draw(rect)
        } else {
            print("No game connected to GameDrawer")
        }
    }
    
    private func addGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.touch(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.touch(_:)))
        self.addGestureRecognizer(swipeGesture)
    }
    
    @objc func touch(_ sender: UIGestureRecognizer) {
        let point = sender.location(in: self)
        game!.onTouch(x: Double(point.x), y: Double(point.y))
        setNeedsDisplay()
    }
    
}

