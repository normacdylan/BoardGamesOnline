//
//  FireBaseFunctions.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-05-02.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation
import Firebase

let Ref: DatabaseReference = Database.database().reference()
let Games = Ref.child("Games")

func getGames(completed: @escaping ([String : String]) -> ()) {
    Games.observe(.value, with: { snapshot in
        var result: [String : String] = [:]
        for child in snapshot.children {
            let game = child as! DataSnapshot
            let name = game.key
            let type = game.value! as! String
            result[name] = type
        }
        completed(result)
    })
}

func amountOfPlayers(game: String, completed: @escaping (Int) -> ()) {
    Ref.child(game).observe(.value, with: { snapshot in
        var result = 0
        for child in snapshot.children {
            let table = child as! DataSnapshot
            let players = table.children.map{$0 as! DataSnapshot}.filter{$0.key != "LatestMove" && $0.key != "Turn"}.count
            result += players
        }
        completed(result)
    })
}

func getTables(game: String, completed: @escaping ([(key: String, players: [String])]) -> ()) {
    Ref.child(game).observe(.value, with: { snapshot in
        var result: [(String, [String])] = []
        for child in snapshot.children {
            let table = child as! DataSnapshot
            let id = table.key
            var players: [String] = []
            for player in table.children {
                let user = player as! DataSnapshot
                if user.key != "LatestMove" && user.key != "Turn" {
                    players.append(user.value! as! String)
                }
            }
            result.append((id, players))
        }
        completed(result)
    })
}

func getPlayersAtTable(game: String, table: String, completed: @escaping ([(String, String)]) -> ()) {
    Ref.child(game).child(table).observe(.value, with: { snapshot in
        var result: [(String, String)] = []
        for child in snapshot.children {
            let user = child as! DataSnapshot
            let key = user.key
            if key != "LatestMove" && key != "Turn" {
                let name = user.value! as! String
                result.append((key,name))
            }
        }
        completed(result)
    })
}

func getPlayersAtTableOnce(game: String, table: String, completed: @escaping ([(String, String)]) -> ()) {
    Ref.child(game).child(table).observeSingleEvent(of: .value, with: { snapshot in
        var result: [(String, String)] = []
        for child in snapshot.children {
            let user = child as! DataSnapshot
            let key = user.key
            if key != "LatestMove" && key != "Turn" {
                let name = user.value! as! String
                result.append((key,name))
            }
        }
        completed(result)
    })
}

func addGame(name: String) {
    let autoKey = Games.childByAutoId()
    autoKey.setValue(name)
}

func addTable(game: String) {
    // Kolla att game finns i Games?
    let autoKey = Ref.child(game).childByAutoId()
    if let user = Auth.auth().currentUser {
        autoKey.child(user.uid).setValue(user.displayName)
        Ref.child(user.uid).setValue(autoKey.key)
        autoKey.child("LatestMove").setValue(-1)
    }
}

func joinTable(game: String, table: String) {
    // Kolla att spel och bord finns
    if let user = Auth.auth().currentUser {
        Ref.child(game).child(table).child(user.uid).setValue(user.displayName)
        Ref.child(user.uid).setValue(table)
    }
}

func leaveTable(game: String, table: String) {
    if let user = Auth.auth().currentUser {
        Ref.child(game).child(table).child(user.uid).removeValue()
        Ref.child(user.uid).removeValue()
        getPlayersAtTableOnce(game: game, table: table) { result in
            if result.count == 0 {
                Ref.child(game).child(table).removeValue()
            }
        }
    }
}

func makeMove(game: String, table: String, move: Int) {
    Ref.child(game).child(table).child("LatestMove").setValue(move)
}

// Kolla om child latestmove finns istället!
func moveMade(game: String, table: String, completed: @escaping (Int) -> ()) {
    Ref.child(game).child(table).child("LatestMove").observe(.value, with: { snapshot in
        let move = snapshot.value! as! Int
        completed(move)
    })
}

func setPlayerTurn(game: String, table: String, playerId: String) {
    Ref.child(game).child(table).child("Turn").setValue(playerId)
    print("Turn value changed to \(playerId)")
}

func isPlayersTurn(game: String, table: String, completed: @escaping (Bool) -> ()) {
    if let userId = Auth.auth().currentUser?.uid {
        Ref.child(game).child(table).child("Turn").observeSingleEvent(of: .value, with: { snapshot in
            let turnId = snapshot.value as! String
            completed(turnId == userId)
        })
    }
}

//observe eller observesingleevent?
func getUserSeat(completed: @escaping (String?) -> ()) {
    if let userId = Auth.auth().currentUser?.uid {
        Ref.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(userId) {
                let tableName = snapshot.childSnapshot(forPath: userId).value as! String
                completed(tableName)
            } else {
                completed(nil)
            }
        })
    }
}

// TODO
func removeViewsObservers() {
    // getGames
    Games.removeAllObservers()
    
    // amountOfPlayers, getTables, getPlayersAtTable
    Games.observeSingleEvent(of: .value, with: { snapshot in
        for child in snapshot.children {
            let game = child as! DataSnapshot
            let path = game.value! as! String
            Ref.child(path).removeAllObservers()
            removeChildrensObservers(parent: Ref.child(path))
        }
    })
    /*
     // getUserSeat
     if let userId = Auth.auth().currentUser?.uid {
     Ref.child(userId).removeAllObservers()
     } */
}

func removeChildrensObservers(parent: DatabaseReference) {
    parent.observeSingleEvent(of: .value, with: { snapshot in
        for child in snapshot.children {
            let path = child as! DataSnapshot
            parent.child(path.key).removeAllObservers()
        }
    })
}

// funktion som hämtar alla users och vilka bord de sitter på?

