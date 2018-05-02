//
//  GameController.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-29.
//  Copyright © 2018 August Posner. All rights reserved.
//

import UIKit
import Firebase

class GameController: UIViewController, GameDelegate {
    var gameView: GameDrawer?
    var game: String?
    var table: String?
    var players: [(String, String)]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gameView = getGameView()
        self.view.addSubview(gameView!)
        
        guard let gameName = game else {return}
        guard let tableName = table  else {return}
        
        title = gameName
        gameView!.game = getGameFromName(gameName: gameName, width: Double(gameView!.bounds.width), height: Double(gameView!.bounds.height))
        gameView!.game!.delegate = self
        
        getPlayersAtTableOnce(game: gameName, table: tableName) { result in
            self.players = result
            if let playerList = self.players {
                setPlayerTurn(game: gameName, table: tableName, playerId: playerList[0].0)
                print("initiated turn")
                self.gameView!.startGame()
            } else {
                print("Failed to set list of players")
            }
        }
        
        moveMade(game: gameName, table: tableName) { move in
            if move != -1 {
                self.gameView!.game?.receive(message: move)
                print("move made at col \(move)")
                self.gameView!.setNeedsDisplay()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let gameName = game else {return}
        guard let tableName = table  else {return}
        
        leaveTable(game: gameName, table: tableName)
    }
    
    func messageSent(message: Int) {
        guard let gameName = game else {return}
        guard let tableName = table  else {return}
        
        isPlayersTurn(game: gameName, table: tableName) { isTurn in
            if isTurn {
                makeMove(game: gameName, table: tableName, move: message)
                if let userID = Auth.auth().currentUser?.uid {
                    if self.players!.count == 2 {
                        let newPlayer = self.players!.filter{$0.0 != userID}[0]
                        setPlayerTurn(game: gameName, table: tableName, playerId: newPlayer.0)
                    } else {
                        print("Only found \(self.players!.count) players")
                    }
                }
            }
        }
    }
    
    func gameOver() {
        gameView!.game!.playing = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Anpassa storlek och position efter andra viewelement?
    func getGameView() -> GameDrawer {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let margin = screenWidth * 0.05
        
        let gameView = GameDrawer(frame:(CGRect(x: margin, y: 0.15 * screenHeight, width: 0.9 * screenWidth, height: 0.5 * screenHeight)))
        gameView.backgroundColor = .white
        
        return gameView
    }

}
