//
//  Game.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-17.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation
import UIKit

protocol Game {
    var width: Double {get}
    var height: Double {get}
    
    func draw(_ rect: CGRect)
    
    func play()
    
    func onTouch(x: Double, y: Double)
    
    //func onTouch(x: Double, y: Double, gesture: UIGestureRecognizer)
}
