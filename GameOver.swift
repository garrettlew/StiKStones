//
//  GameOver.swift
//  StiKStones
//
//  Created by Gilbert Lew on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

import GameKit

class GameOver: CCNode {
    
    weak var infoButton: CCButton!

    weak var lastScoreLabel: CCLabelTTF!
    var lastScore: Int = 0 {
        didSet {
            lastScoreLabel.string = "\(lastScore)"
        }
    }
    
    weak var highScoreLabel: CCLabelTTF!
    var highScore: Int = 0 {
        didSet {
            highScoreLabel.string = "\(highScore)"
        }
    }
}

// MARK: Game Center Handling extension Gameplay: 
extension GameOver: GKGameCenterControllerDelegate {
    
    func showLeaderboard() {
        var viewController = CCDirector.sharedDirector().parentViewController!
        var gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }

    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
