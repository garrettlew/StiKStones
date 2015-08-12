//
//  GameOver.swift
//  StiKStones
//
//  Created by Gilbert Lew on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

import Mixpanel

import GameKit

class GameOver: CCNode {
    
    var mixpanel = Mixpanel.sharedInstance()
    
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
    
    override func onEnter() {
        checkForNewHighScores()
        super.onEnter()
    }
    
//    func openGameCenter() {
//        showLeaderboard()
//    }
    
    func reportHighScoreToGameCenter(){

        var scoreReporter = GKScore(leaderboardIdentifier: "StiKsandStonesSinglePlayerLeaderboard")
        scoreReporter.value = Int64(highScore)
        var scoreArray: [GKScore] = [scoreReporter]
        GKScore.reportScores(scoreArray, withCompletionHandler: {(error : NSError!) -> Void in
            if error != nil
            {

            } else {


            }
        })
    }
    
    func checkForNewHighScores(){
        if lastScore == highScore {
            reportHighScoreToGameCenter()
        }
    }
    
    func shareButtonTapped() {
        
        mixpanel.track("ButtonPressed", properties: ["ButtonType": "Share"])
        
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
        mixpanel.track("ButtonPressed", properties: ["ButtonType": "Game Center"])
        var viewController = CCDirector.sharedDirector().parentViewController!
        var gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        gameCenterViewController.leaderboardIdentifier = "StiKsandStonesSinglePlayerLeaderboard"
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }

    // Delegate methods
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController!) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

