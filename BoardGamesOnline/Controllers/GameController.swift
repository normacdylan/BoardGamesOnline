//
//  GameController.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-29.
//  Copyright © 2018 August Posner. All rights reserved.
//

import UIKit
import Firebase

class GameController: UIViewController {

    var gameView: GameDrawer?
    var game: String?
    var table: String?
    var players: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        gameView = getGameView()
        self.view.addSubview(gameView!)
        
        guard let gameName = game else {return}
        guard let tableName = table  else {return}
        
        gameView!.game = getGameFromName(gameName: gameName, width: Double(gameView!.bounds.width), height: Double(gameView!.bounds.height))
        
        getPlayersAtTable(game: gameName, table: tableName) { result in
            self.players = result
        }
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
