//
//  Connect4.swift
//  BoardGamesOnline
//
//  Created by August Posner on 2018-04-17.
//  Copyright © 2018 August Posner. All rights reserved.
//

import Foundation
import UIKit

//Flytta och göra global?
enum Player {
    case Player1, Player2
}

enum Direction: Int {
    case Vertical = 0, Horizontal, DiagonalUp, DiagonalDown
}

class Board {
    let rows: Int
    let columns: Int
    var board: [[Player?]]
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        board = Array(repeating: Array(repeating: nil, count: columns), count: rows)
    }
    
    subscript(row: Int, column: Int) -> Player? {
        return withinBoard(row, column) ? board[row][column] : nil
    }
    
    subscript(startPoint: (row: Int, column: Int), direction: Direction) -> [Player?]? {
        if !withinBoard(startPoint.row, startPoint.column) {
            return nil
        }
        
        switch direction {
        case .Horizontal:
            return board[startPoint.row]
        case .Vertical:
            return board.map{$0[startPoint.column]}
        case .DiagonalUp:
            return board[...startPoint.row].reversed().enumerated().filter{startPoint.column + $0.0 < columns}.map{$0.1[startPoint.column + $0.0]}
        case .DiagonalDown:
            return board[startPoint.row...].enumerated().filter{startPoint.column + $0.0 < columns}.map{$0.1[startPoint.column + $0.0]}
        }
    }
    
    private func getOpenSlot(column: Int) -> Int? {
        if column > columns {
            print("column \(column) out of range")
            return nil
        }
        
        if board[0][column] != nil {
            print("column is full")
            return nil
        }
        
        for slot in 1..<rows {
            if board[slot][column] != nil {
                return slot - 1
            }
        }
        return rows - 1
    }
    
    func isFull() -> Bool {
        return board[0].filter{$0 == nil}.count == 0
      //  return board[0].contains(nil)
    }
    
    private func withinBoard(_ row: Int = 0, _ column: Int = 0) -> Bool {
        return row < rows && row > -1 && column < columns && column > -1
    }
    
    func canPlaceCoin(column: Int) -> Bool {
        return getOpenSlot(column: column) != nil
    }
    
    func placeCoin(column: Int, player: Player) -> Bool {
        if let slot = getOpenSlot(column: column) {
            board[slot][column] = player
            return true
        }
        return false
    }
}

struct WinInfo {
    let player: Player
    let slot: (row: Int, column: Int)
    let direction: Direction
    
    init(player: Player, slot: (Int, Int), direction: Direction) {
        self.player = player
        self.slot = slot
        self.direction = direction
    }
}

extension Board {
    private func fourConsecutive(list: [Player?]?) -> Int? {
        guard let array = list else {return nil}
        
        if array.count < 4 {
            return nil
        }
        for i in 0...array.count - 4 {
            if array[i] == array[i + 1] && array[i + 1] == array[i + 2] && array[i + 2] == array[i + 3] && array[i] != nil {
                return i
            }
        }
        return nil
    }
    
    func getWinner() -> WinInfo? {
        for dir in 0...3 {
            for row in 0..<rows {
                for col in 0..<columns {
                    if let index = fourConsecutive(list: self[(row, col), Direction(rawValue: dir)!]) {
                        switch Direction(rawValue: dir)! {
                        case .Vertical:
                            return WinInfo(player: self[index, col]!, slot: (index, col), direction: Direction(rawValue: dir)!)
                        case .Horizontal:
                            return WinInfo(player: self[row, index]!, slot: (row, index), direction: Direction(rawValue: dir)!)
                        case .DiagonalDown:
                            return WinInfo(player: self[row + index, col + index]!, slot: (row + index, col + index), direction: Direction(rawValue: dir)!)
                        case .DiagonalUp:
                            return WinInfo(player: self[row, col]!, slot: (row, col), direction: Direction(rawValue: dir)!)
                        }
                    }
                }
            }
        }
        return nil
    }
}


class Connect4Game: Game {
    var width: Double
    var height: Double
    var playing = false
    var delegate: GameDelegate?
    
    let topMargin: Double
    let coinRadius: Double
    let yMargin: Double
    
    let board = Board(rows: 6, columns: 7)
    let players = [Player.Player1, Player.Player2]
    
    var turn: Player
    
    init(width: Double, height: Double) {
        self.width = width
        self.height = height
        topMargin = 0.3 * height
        coinRadius = width / Double(board.columns * 3 + 1)
        yMargin = ((height - topMargin) - (coinRadius * Double(board.rows * 2))) / Double(board.rows + 1)
        turn = .Player1
    }
    
    func draw(_ rect: CGRect) {
        // Draw Board
        let boardRect = CGRect(x: 0, y: topMargin, width: width, height: height - topMargin)
        let rectPath = UIBezierPath(rect: boardRect)
        UIColor.blue.setFill()
        rectPath.fill()
        
        // Draw slots and coins
        for row in 0..<board.rows {
            for column in 0..<board.columns {
                let x = getCoinCoordinates(row, column).x
                let y = getCoinCoordinates(row, column).y
                let coinPath = UIBezierPath(arcCenter: CGPoint(x: x, y: y), radius: CGFloat(coinRadius), startAngle: 0, endAngle: CGFloat(2 * Float.pi), clockwise: true)
                
                if let coin = board[row, column] {
                    let color = coin == .Player1 ? UIColor.red : UIColor.yellow
                    color.setFill()
                } else {
                    UIColor.white.setFill()
                }
                
                coinPath.fill()
            }
        }
        
        // Draw line over winning coins
        if let winner = board.getWinner() {
            let linePath = UIBezierPath()
            let startPoint = getCoinCoordinates(winner.slot.row, winner.slot.column)
            linePath.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
            var endPoint: (x: Double, y: Double)
            
            switch winner.direction {
            case .Horizontal:
                endPoint = getCoinCoordinates(winner.slot.row, winner.slot.column + 3)
            case .Vertical:
                endPoint = getCoinCoordinates(winner.slot.row + 3, winner.slot.column)
            case .DiagonalUp:
                endPoint = getCoinCoordinates(winner.slot.row - 3, winner.slot.column + 3)
            case .DiagonalDown:
                endPoint = getCoinCoordinates(winner.slot.row + 3, winner.slot.column + 3)
            }
            
            linePath.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
            UIColor.black.setStroke()
            linePath.lineWidth = 5
            linePath.stroke()
        }
    }
    
    func getEventText() -> String {
        return ""
    }
    
    func getInfoText() -> String {
        return "First to get four coins in a row wins. Tap above a column to drop coin."
    }
    
    func getMoveText(move: Int) -> String {
        let countNames = ["first", "second", "third", "fourth", "fifth", "sixth", "seventh"]
        return "dropped a coin in the \(countNames[move]) column."
    }
    
    func send(message: Int) {
        delegate?.messageSent(message: message)
    }
    
    // Lägg mynt i column om möjligt
    func receive(message: Int) {
        if board.canPlaceCoin(column: message) {
            if board.placeCoin(column: message, player: turn) {
                print("coin placed at column: \(message)")
                turn = players.filter{$0 != turn}[0]
                if let winner = board.getWinner() {
                    print("game over")
                    delegate?.gameOver(result: "\(winner.player)")
                } else if board.isFull() {
                    print("game over")
                    delegate?.gameOver(result: "draw")
                }
            }
        }
    }
    
    func isOver() {
        
    }
    
    // Flera olika typer av touch för att flytta och släppa mynt. UITouchGesture?
    func onTouch(x: Double, y: Double) {
        if y < topMargin {
            for col in 0..<board.columns {
             //   print("column \(col), x-value: \(getCoinCoordinates(0,col).x)")
                if abs(x - getCoinCoordinates(0, col).x) < coinRadius {
                    if board.canPlaceCoin(column: col) {
                        send(message: col)
                    }
                }
            }
        }
    }
    
    private func getCoinCoordinates(_ row: Int, _ column: Int) -> (x: Double, y: Double) {
        let x = coinRadius * 2 + (Double(column * 3) * coinRadius)
        let y = topMargin + coinRadius + yMargin + (Double(row * 2) * coinRadius) + (Double(row) * yMargin)
        return (x, y)
    }
    
    
    
}
