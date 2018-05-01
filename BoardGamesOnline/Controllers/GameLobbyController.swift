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
    
    @IBOutlet weak var createTableButton: UIBarButtonItem!
    @IBOutlet weak var leaveTableButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupView()
      
       // funktion som observerar när users bord blir fullt
    }
    
    func setupView() {
        if let name = game {
            title = name
            
            getTables(game: name) { result in
                self.tables = result
                self.collectionView?.reloadData()
            }
            
            getUserSeat() { seat in
                self.createTableButton.isEnabled = seat == nil
                self.leaveTableButton.isEnabled = seat != nil
            }
        } else {
            title = "Unable To Load Contents"
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        getUserSeat() { result in
            guard let name = self.game else {return}
            guard let seat = result else {return}
            
            leaveTable(game: name, table: seat)
        }
        
    //    removeViewsObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pressedLeaveTable(_ sender: Any) {
        getUserSeat() { result in
            guard let name = self.game else {return}
            guard let seat = result else {return}
            
            leaveTable(game: name, table: seat)
            self.setupView()
        }
    }
    
    @IBAction func pressedCreateTable(_ sender: Any) {
        getUserSeat() {result in
            if result == nil {
                addTable(game: self.game!)
                self.setupView()
            }
        }
    }
    
    @IBAction func pressedLogOut(_ sender: Any) {
        viewDidDisappear(false)
        
        try! Auth.auth().signOut()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginController
        self.present(vc, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        getUserSeat() { result in
            if result == nil {
                let tableKey = self.tables[indexPath.row].0
                let players = self.tables[indexPath.row].1
                print("Players at didSelect: \(players.count)")
                if players.count < 2 {
                    guard let name = self.game else {return}
                    joinTable(game: name, table: tableKey)
                    self.setupView()
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Game") as! GameController
                    vc.game = self.game
                    vc.table = tableKey
                    self.present(vc, animated: true, completion: nil)
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
        
        cell.tableImage.image = UIImage.init(named: "Table")
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
