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
    weak var leaderboardButton: CCButton!

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
    
    override func  onEnter() {
        checkForNewHighScores()
        super.onEnter()
    }
    
    func openGameCenter() {
        mixpanel.track("Open Leaderboard", parameters: ["LeaderboardType": "Game Center"])
        showLeaderboard()
    }
    
    func reportHighScoreToGameCenter(){
        var scoreReporter = GKScore(leaderboardIdentifier: "StiKsandStonesLeaderboard")
        scoreReporter.value = Int64(highScore)
        var scoreArray: [GKScore] = [scoreReporter]
        GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
            if error != nil {
                println("Game Center: Score Submission Error")
            }
        })
    }
    
    func checkForNewHighScores(){
        if lastScore == highScore {
            reportHighScoreToGameCenter()
        }
    }
    
    func shareButtonTapped() {
        
        mixpanel.track("Share", parameters: ["ShareType": "Share Button"])
        
        var scene = CCDirector.sharedDirector().runningScene
        var node: AnyObject = scene.children[0]
        var screenshot = screenShotWithStartNode(node as! CCNode)
        
        let sharedText = "I just Rekt you in StiKs and Stones."
        let itemsToShare = [screenshot, sharedText]
        
        var excludedActivities = [ UIActivityTypeAssignToContact,
            UIActivityTypeAddToReadingList, UIActivityTypePostToTencentWeibo]
        
        var controller = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        controller.excludedActivityTypes = excludedActivities
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func screenShotWithStartNode(node: CCNode) -> UIImage {
        CCDirector.sharedDirector().nextDeltaTimeZero = true
        var viewSize = CCDirector.sharedDirector().viewSize()
        var rtx = CCRenderTexture(width: Int32(viewSize.width), height: Int32(viewSize.height))
        rtx.begin()
        node.visit()
        rtx.end()
        return rtx.getUIImage()
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

