//
//  GameList.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-30.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation

func getGameFromName(gameName: String, width: Double, height: Double) -> Game? {
    switch gameName {
    case "Connect4":
        return Connect4Game(width: width, height: height)
    default:
        return nil
    }
}
