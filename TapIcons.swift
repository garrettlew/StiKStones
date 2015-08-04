//
//  TapIcons.swift
//  StiKStones
//
//  Created by Gilbert Lew on 7/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation


class TapIcons: CCNode {
    
    weak var tapLeft: CCNode!
    
    weak var tapRight: CCNode!
    
    func didLoadFromCCB() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fadeOut:", name: "gameStarted", object: nil)
    }
    
    func fadeOut(notification: NSNotification) {
        tapLeft.visible = false
        tapRight.visible = false
    }
    
    override func onExit() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func startTapIconsAnimation() {
        self.animationManager.runAnimationsForSequenceNamed("TapIconsAnimation")
    }
}