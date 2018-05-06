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
        Ref.child(user.uid).child("Table").setValue(autoKey.key)
        Ref.child(user.uid).child("Game").setValue(game)
        autoKey.child("LatestMove").setValue(-1)
    }
}

func joinTable(game: String, table: String) {
    // Kolla att spel och bord finns?
    if let user = Auth.auth().currentUser {
        Ref.child(game).child(table).child(user.uid).setValue(user.displayName)
        Ref.child(user.uid).child("Table").setValue(table)
        Ref.child(user.uid).child("Game").setValue(game)
    }
}

func leaveTable(game: String, table: String, keepGame: Bool) {
    if let user = Auth.auth().currentUser {
        Ref.child(game).child(table).child(user.uid).removeValue()
        Ref.child(user.uid).child("Table").removeValue()
        if !keepGame {
            Ref.child(user.uid).child("Game").removeValue()
        }
        getPlayersAtTableOnce(game: game, table: table) { result in
            if result.count == 0 {
                Ref.child(game).child(table).removeValue()
            }
        }
    }
}

func findAndLeaveTable() {
    print("Finding and leaving table")
    if let _ = Auth.auth().currentUser {
        getUserGame() { gameResult in
            guard let game = gameResult else {
                print("No game found")
                return
            }
            
            getUserSeat() { tableResult in
                guard let table = tableResult else {
                    print("No table found")
                    return
                }
                
                leaveTable(game: game, table: table, keepGame: false)
                print("Left table")
            }
        }
    } else {
        print("No user found")
    }
}

func deleteGameTrace() {
    if let userId = Auth.auth().currentUser?.uid {
        getUserGame(completed: { result in
            guard let _ = result else {return}
            Ref.child(userId).removeValue()
        })
    }
}

func opponentLeft(game: String, table: String, completed: @escaping (Bool) -> ()) {
    Ref.child(game).child(table).observe(.childRemoved, with: { snapshot in
        var players = 0
        for child in snapshot.children {
            let player = child as! DataSnapshot
            if player.key != "LatestMove" && player.key != "Turn" {
                players += 1
            }
        }
        completed(players < 2)
    })
}

func makeMove(game: String, table: String, move: Int) {
    Ref.child(game).child(table).child("LatestMove").setValue(move)
}

func moveMade(game: String, table: String, completed: @escaping (Int?) -> ()) {
    Ref.child(game).child(table).child("Turn").observe(.value, with: { snapshot in
        Ref.child(game).child(table).child("LatestMove").observeSingleEvent(of: .value, with: { snap in
            let move = snap.value as! Int?
            completed(move)
        })
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

func getUserSeat(completed: @escaping (String?) -> ()) {
    if let userId = Auth.auth().currentUser?.uid {
        Ref.observeSingleEvent(of: .value, with: { result in
            if result.hasChild(userId) {
                Ref.child(userId).observeSingleEvent(of: .value, with: { snap in
                    if snap.hasChild("Table") {
                        Ref.child(userId).child("Table").observeSingleEvent(of: .value, with: { snapshot in
                            if let table = snapshot.value as? String {
                                completed(table)
                            } else {
                                completed(nil)
                            }
                        })
                    } else {
                        completed(nil)
                    }
                })
            } else {
                completed(nil)
            }
        })
    } else {
        completed(nil)
    }
}

func getUserGame(completed: @escaping (String?) -> ()) {
    if let userId = Auth.auth().currentUser?.uid {
        Ref.observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.hasChild(userId) {
                let gameName = snapshot.childSnapshot(forPath: userId).childSnapshot(forPath: "Game").value as! String
                completed(gameName)
            } else {
                completed(nil)
            }
        })
    }
}


