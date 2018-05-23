//
//  GameLobbyController.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-29.
//  Copyright © 2018 August Posner. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class GameLobbyController: UICollectionViewController {

    var game: String?
    var tables: [(String, [String])] = []
    var goingToGame = false
    
    @IBOutlet weak var createTableButton: UIBarButtonItem!
    @IBOutlet weak var leaveTableButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
    }
    
    func checkIfTableIsFull(table: String) {
        guard let gameName = game else {return}
        getPlayersAtTable(game: gameName, table: table) { result in
            if result.count > 1 {
                self.goingToGame = true
            //    self.performSegue(withIdentifier: "toGameSegue", sender: nil)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toGameSegue", sender: nil)
                }
                Ref.child(gameName).child(table).removeAllObservers()
            }
        }
    }
    
    func setupView() {
        getUserGame() { result in
            if let game = result {
                self.game = game
            }
        
            if let name = self.game {
                self.title = name
            
                getUserSeat() { seat in
                    self.createTableButton.isEnabled = seat == nil
                    self.leaveTableButton.isEnabled = seat != nil
                }
                
                getTables(game: name) { result in
                    self.tables = result
                    self.collectionView?.reloadData()
                }
            } else {
                self.title = "Unable To Load Contents"
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !goingToGame {
            getUserSeat() { result in
                guard let name = self.game else {return}
                guard let seat = result else {return}
                
                leaveTable(game: name, table: seat, keepGame: false)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pressedLeaveTable(_ sender: Any) {
        getUserSeat() { result in
            guard let name = self.game else {return}
            guard let seat = result else {return}
            
            leaveTable(game: name, table: seat, keepGame: false)
            self.setupView()
        }
    }
    
    @IBAction func pressedCreateTable(_ sender: Any) {
        print("Creating table")
        getUserSeat() {result in
            if result == nil {
                addTable(game: self.game!)
                self.setupView()
                getUserSeat() { seat in
                    if let table = seat {
                        self.checkIfTableIsFull(table: table)
                    } else {
                        print("no table found")
                    }
                }
            }
        }
    }
    
    @IBAction func pressedLogOut(_ sender: Any) {
        viewDidDisappear(true)
        
        findAndLeaveTable()
        try! Auth.auth().signOut()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getUserSeat() { result in
            if result == nil {
                let tableKey = self.tables[indexPath.row].0
                let players = self.tables[indexPath.row].1
                
                if players.count < 2 {
                    guard let name = self.game else {return}
                    joinTable(game: name, table: tableKey)
                    self.setupView()
                    
                    self.goingToGame = true
              //      self.performSegue(withIdentifier: "toGameSegue", sender: nil)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "toGameSegue", sender: nil)
                    }
                }
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tables.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! TableCell
        
        if tables[indexPath.row].1.count > 0 {
            cell.player1Label.text = tables[indexPath.row].1[0]
        } else {
            cell.player1Label.text = "Empty Seat"
        }
        
        if tables[indexPath.row].1.count > 1 {
            cell.player2Label.text = tables[indexPath.row].1[1]
        } else {
            cell.player2Label.text = "Empty Seat"
        }
        
        cell.tableImage.image = tables[indexPath.row].1.count < 2 ? UIImage.init(named: "Table") : UIImage.init(named: "FullTable")
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let gameName = game else {
            print("Did not finish prepare for segue to GameController")
            return
        }
        
        getUserSeat() { result in
            if let seat = result {
                let destination = segue.destination as! GameController
                print("is the gamecontroller loaded?")
                destination.game = gameName
                print("Destination: \(segue.identifier!), destination.game = \(destination.game!)")
                destination.table = seat
                print("Destination: \(segue.identifier!), destination.table = \(destination.table!)")
            }
        }
    }
}
