//
//  FirebaseConstants.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-26.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation
import Firebase

let Ref: DatabaseReference = Database.database().reference()
let Games = Ref.child("Games")

func getGames(completed: @escaping ([String : String]) -> ()) {
    Games.observeSingleEvent(of: .value, with: { (snapshot) in
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
    Ref.child(game).observeSingleEvent(of: .value, with: { snapshot in
        var result = 0
        for child in snapshot.children {
            let table = child as! DataSnapshot
            result += Int(table.childrenCount)
        }
        completed(result)
    })
}

// Observe istället för single event? (Med removeObserver!)
func getTables(game: String, completed: @escaping ([String : [String]]) -> ()) {
    Ref.child(game).observeSingleEvent(of: .value, with: { (snapshot) in
        var result: [String : [String]] = [:]
        for child in snapshot.children {
            let table = child as! DataSnapshot
            let id = table.key
            var players: [String] = []
            for player in table.children {
                let user = player as! DataSnapshot
                players.append(user.value! as! String)
            }
            result[id] = players
        }
        completed(result)
    })
}

func addGame(name: String) {
    let autoKey = Games.childByAutoId()
    autoKey.setValue(name)
 //   Ref.child(name)
}

func addTable(game: String) {
    // Kolla att game finns i Games?
    let autoKey = Ref.child(game).childByAutoId()
    if let user = Auth.auth().currentUser {
        autoKey.child("Player1").setValue(user.displayName)
    }
}

func joinTable(game: String, table: String) {
    // Kolla att spel och bord finns
    // Hämta antal spelare vid bordet?
    if let user = Auth.auth().currentUser {
        Ref.child(game).child(table).childByAutoId().setValue(user.displayName)
    }
}

func leaveTable(game: String, table: String) {
    if let user = Auth.auth().currentUser {
     //   Ref.child(game).child(table).child(user).removeValue()
    }
}

// funktion som hämtar alla users och vilka bord de sitter på?













