//
//  ViewController.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-17.
//  Copyright © 2018 August Posner. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    var gameView: GameDrawer?
    var game: Game?
    
    var turn = Player.Player1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        getGames() { (result) in
            for a in result {
                print(a)
            }
        }
        
        getTables(game: "Connect4") { (result) in
            for a in result {
                print(a)
            }
        }
        
        gameView = getGameView()
        self.view.addSubview(gameView!)
        
        game = Connect4Game(width: Double(gameView!.bounds.width), height: Double(gameView!.bounds.height))
        gameView!.game = game
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(_:)))
        self.gameView!.addGestureRecognizer(tapGesture)
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: gameView!)
        print("tapped x:\(point.x) y:\(point.y)")
        game!.onTouch(x: Double(point.x), y: Double(point.y))
        gameView!.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getGameView() -> GameDrawer {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let margin = screenWidth * 0.05
        
        let gameView = GameDrawer(frame:(CGRect(x: margin, y: margin, width: 0.9 * screenWidth, height: 0.5 * screenHeight)))
        gameView.backgroundColor = .white
        
        return gameView
    }
}


