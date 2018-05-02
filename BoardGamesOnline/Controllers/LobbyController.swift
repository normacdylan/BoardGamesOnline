//
//  LobbyController.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-26.
//  Copyright © 2018 August Posner. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class LobbyController: UICollectionViewController {

    var gameNames: [String] = []
    var playersPerGame: [String : Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Leave tables?
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGames() { result in
            self.gameNames = result.map{$0.value}
            for game in self.gameNames {
                amountOfPlayers(game: game) { result in
                    self.playersPerGame[game] = result
                    self.collectionView!.reloadData()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      //  removeViewsObservers()
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func pressedLogOut(_ sender: Any) {
        try! Auth.auth().signOut()
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Login") as! LoginController
        self.present(vc, animated: true, completion: nil)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! LobbyCell
        let destination = segue.destination as! GameLobbyController
        destination.game = cell.label.text
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LobbyCell
        
        cell.label.text = gameNames[indexPath.row]
        if let players = playersPerGame[gameNames[indexPath.row]] {
            cell.playersLabel.text = "\(players) players"
        }
        
        if let pic = UIImage.init(named: gameNames[indexPath.row]) {
            cell.image.image = pic
        } else {
            cell.image.image = UIImage.init(named: "NoImageFound")
        }
        
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
