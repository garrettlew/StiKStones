//
//  GameOver.swift
//  StiKStones
//
//  Created by Gilbert Lew on 7/31/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import Foundation

class GameOver: CCNode {
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
