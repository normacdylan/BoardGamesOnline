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
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("game did load")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("game did appear")
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        gameView = getGameView()
        self.view.addSubview(gameView!)
        
        print("about to check for games")
        
        guard let gameName = game else {
            print("no game found")
        //    shutDown()
            return
        }
    
        guard let tableName = table  else {
            print("no table found")
         //   shutDown()
            return
        }
        
        gameView!.game = getGameFromName(gameName: gameName, width: Double(gameView!.bounds.width), height: Double(gameView!.bounds.height))
        gameView!.game!.delegate = self
        
        infoLabel.text = gameView!.game!.getInfoText()
        
        getPlayersAtTableOnce(game: gameName, table: tableName) { result in
            self.players = result
            if let playerList = self.players {
                setPlayerTurn(game: gameName, table: tableName, playerId: playerList[0].0)
                self.gameView!.startGame()
                if let user = Auth.auth().currentUser {
                    let opponent = playerList.filter{$0.0 != user.uid}[0].1
                    isPlayersTurn(game: gameName, table: tableName, completed: { isTurn in
                        self.eventLabel.text = isTurn ? "You start." : "\(opponent) starts."
                    })
                }
            } else {
                print("Failed to set list of players")
            }
        }
        
        moveMade(game: gameName, table: tableName) { moveResult in
            if let move = moveResult {
                if move != -1 {
                    self.gameView!.game?.receive(message: move)
                    print("move made at col \(move)")
                    self.gameView!.setNeedsDisplay()
                    
                    if self.gameView!.game!.playing {
                        if let user = Auth.auth().currentUser {
                            let opponent = self.players!.filter{$0.0 != user.uid}[0].1
                            isPlayersTurn(game: gameName, table: tableName) { isTurn in
                                if isTurn {
                                    self.eventLabel.text = "\(opponent) \(self.gameView!.game!.getMoveText(move: move)) Your turn."
                                } else {
                                    self.eventLabel.text = "You \(self.gameView!.game!.getMoveText(move: move)) \(opponent)'s turn."
                                }
                            }
                        }
                    }
                }
            }
        }
        
        opponentLeft(game: gameName, table: tableName) { didLeave in
            if didLeave && self.gameView!.game!.playing {
                self.gameOver(result: "abandoned")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let gameName = game else {return}
        guard let tableName = table  else {return}
        
        Ref.child(gameName).child(tableName).removeAllObservers()
        Ref.child(gameName).child(tableName).child("Turn").removeAllObservers()
        
        leaveTable(game: gameName, table: tableName, keepGame: true)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
   
    func messageSent(message: Int) {
        guard let gameName = game else {return}
        guard let tableName = table  else {return}
        
        if !gameView!.game!.playing {
            return
        }
        
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
    
    func gameOver(result: String) {
        gameView!.game!.playing = false
        
        infoLabel.text = ""
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.setToolbarHidden(false, animated: true)
        
        switch result {
        case "draw":
            eventLabel.text = "Game Over! It's a draw!"
        case "Player1":
            if let userId = Auth.auth().currentUser?.uid {
                if userId == players![0].1 {
                    self.eventLabel.text = "Game Over! You win!"
                } else {
                    self.eventLabel.text = "Game Over! \(players![0].1) wins!"
                }
            }
        case "Player2":
            if let userId = Auth.auth().currentUser?.uid {
                if userId == players![1].1 {
                    self.eventLabel.text = "Game Over! You win!"
                } else {
                    self.eventLabel.text = "Game Over! \(players![1].1) wins!"
                }
            }
        case "abandoned":
            guard let gameName = game else {
                eventLabel.text = "Too few players. Game over."
                return
            }
            guard let tableName = table else {
                eventLabel.text = "Too few players. Game over."
                return
            }
            
            getPlayersAtTableOnce(game: gameName, table: tableName) { result in
                if let userId = Auth.auth().currentUser?.uid {
                    self.eventLabel.text = result[0].0 == userId ? "Your opponent left! You win!" : "You left the game! Your opponent won!"
                }
            }
        default:
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func shutDown() {
        print("shutting down")
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Lobby") as! LobbyController
        self.present(vc, animated: true, completion: nil)
    }
    
    func getGameView() -> GameDrawer {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let margin = screenWidth * 0.05
        
        let gameView = GameDrawer(frame:(CGRect(x: margin, y: 0.25 * screenHeight, width: 0.9 * screenWidth, height: 0.45 * screenHeight)))
        gameView.backgroundColor = .white
        
        return gameView
    }

}
