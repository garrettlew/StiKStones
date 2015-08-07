import Foundation

import GameKit

enum GameState {
    case Ready, Playing, GameOver
}

enum GameLevel {
    case Begin, Early, EarlyMid, Mid, LateMid, Late, VeryLate, AlmostGod, God
}

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    
    weak var stik: CCSprite!
    
    weak var squareblock: CCSprite!
    
    weak var tapRight: CCSprite!
    
    weak var tapLeft: CCSprite!
    
    weak var gamePhysicsNode: CCPhysicsNode!
    
    var pivotJoint: CCPhysicsJoint?

    weak var instruction1: CCLabelTTF!
    weak var instruction2: CCLabelTTF!
    
    weak var scoreLabel: CCLabelTTF!
    var score : Float = 0
    
    weak var highScoreLabel: CCLabelTTF!
    var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("myHighScore") ?? 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey:"myHighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    weak var lastScoreLabel: CCLabelTTF!
    var lastScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("myLastScore") ?? 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(lastScore, forKey:"myLastScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var gameState: GameState = .Ready
    var gameLevel: GameLevel = .Begin
    
    var attributionScreen: Attributions!
    var gameOverScreen: GameOver!
    
    var yStik : CGFloat!   //StiK y pos
    var xStik : CGFloat!    // StiK x pos
    var yBlock : CGFloat! //square block y pos
    
    let screenHalf = CCDirector.sharedDirector().viewSize().width / 2

    var stones : [CCNode] = []
    
    var coins : [CCNode] = []
    
    let screenHeight = CCDirector.sharedDirector().viewSize().height
    let screenWidth = CCDirector.sharedDirector().viewSize().width

    var lastStikPosition : CGPoint = CGPoint(x: 0 , y: 0)
    
    var gameTimer: Float = 0
    
    var anotherWaveTimer: Float = 0
    var waveRate: Float = 3.0
    
    var anotherCoinTimer: Float = 0
    
    var instructionsVisible = true
    
    var inAttributionScreen = false
    
    var didRestart = false
    
    var dropDownFinished = false
    
    func setUpGameCenter() {
        let gameCenterInteractor = GameCenterInteractor.sharedInstance
        gameCenterInteractor.authenticationCheck()
    }
    
    func didLoadFromCCB() {
        
        setUpGameCenter()
        
//        gamePhysicsNode.debugDraw = true
        
        gamePhysicsNode.collisionDelegate = self
        
        userInteractionEnabled = true
        
        yBlock = squareblock.position.y
        
        highScoreLabel.string = String(Int(highScore))

    }
    
    override func onEnter() {
        squareblock.position.x = screenWidth / 2
        squareblock.position.y = screenWidth * 0.1
        stik.position.x = screenWidth / 2
        stik.position.y = screenHeight * 0.53
        super.onEnter()
    }
    
    func dropDownLastScore() {
        
        if instructionsVisible {
            instruction1.runAction(CCActionFadeOut(duration: 0.3))
            instruction2.runAction(CCActionFadeOut(duration: 0.3))
        }
        
        scoreLabel.runAction(CCActionFadeOut(duration: 0.3))
        
        // adds dropdown
        gameOverScreen = CCBReader.load("GameOver", owner: self) as! GameOver
        gameOverScreen.lastScore = lastScore
        gameOverScreen.highScore = highScore
        self.addChild(gameOverScreen)

    }
    
    func dropDownDone() {
        dropDownFinished = true
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        let launchDirection = CGPoint(x: 1, y: 0)
        let screenHeight = CCDirector.sharedDirector().viewSize().height
        let touchLocation = touch.locationInWorld()
        var xTouch = touch.locationInWorld().x
        var yTouch = touch.locationInWorld().y
        
        // game can only start once initial animations finish
        if stik.visible {
            if gameState == .Ready {
                
                gameState = .Playing
                
                NSNotificationCenter.defaultCenter().postNotificationName("gameStarted", object: nil)
                
            }
        }
        
        // MARK: Controls
        if gameState == .Playing {
            
            var xForce = CGFloat(1650)
            
            // tap sides; can only tap between current y pos of stik and y pos of block
            if xTouch < screenHalf {
                stik.physicsBody.applyImpulse(ccpMult(launchDirection, xForce))  //left side
                
                tapLeft.position = touchLocation
                tapLeft.visible = true
                tapLeft.runAction(CCActionFadeOut(duration: 0.3))
                
                // Steriods, So ppl have a chance to bring the stick up wen its low
                if yStik < 2 * screenHeight/5 {
                    stik.physicsBody.applyImpulse(ccpMult(launchDirection, 3300))
                }
                
            } else {
                stik.physicsBody.applyImpulse(ccpMult(launchDirection, -(xForce)))  //right side
                
                tapRight.position = touchLocation
                tapRight.visible = true
                tapRight.runAction(CCActionFadeOut(duration: 0.3))
                
                // Steriods, So ppl have a chance to bring the stick up wen its low
                if yStik < 2 * screenHeight/5 {
                    stik.physicsBody.applyImpulse(ccpMult(launchDirection, -(3300)))
                }
            }
        }
        
        if gameState == .GameOver && !didRestart && dropDownFinished && !inAttributionScreen {
            didRestart = true
            restart()
        }
    }
    
    func pulseScore() {
        let squish = CCActionScaleTo(duration: 0.2, scaleX: 1.2, scaleY: 1.8)
        let unsquish = CCActionScaleTo(duration: 0.1, scaleX: 1.0, scaleY: 1.5)

      
        let makeYellow = CCActionCallBlock(block: {
            self.scoreLabel.fontColor = CCColor(red: 0.95, green: 0.9, blue: 0.15)
        })
        
        let changeColorBack = CCActionCallBlock(block: {
            self.scoreLabel.fontColor = CCColor(red: 1.0, green: 1.0, blue: 1.0)
        })
        
        let seq = CCActionSequence(array: [makeYellow, squish, unsquish, changeColorBack])
        
        scoreLabel.runAction(seq)
        
    }
    
    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, coin: Coins!, stik: CCSprite!) {
        score += 3
        pulseScore()
        coin.removeFromParent()
        coins.removeAtIndex(find(coins, coin)!)
    }
    
    func spawnNewCoin() {
        
        
        // create and add a new coin
        var rand = CGFloat (CCRANDOM_0_1())
        let coin = CCBReader.load("Coins") as! Coins
        coin.position = ccp(CGFloat(clampf(Float(screenWidth * rand), Float(screenWidth/4), Float(screenWidth - screenWidth/4))), CGFloat(screenHeight + coin.contentSize.height))
        gamePhysicsNode.addChild(coin)
        coins.append(coin)

    }
    
    func removeCoin() {
        
        //removes Coins when reach bottom of screen
        for coin in coins.reverse() {
            let coinWorldPosition = gamePhysicsNode.convertToWorldSpace(coin.position)
            let coinScreenPosition = convertToNodeSpace(coinWorldPosition)
            
            if coinScreenPosition.y < (-coin.contentSize.height) {
                coin.removeFromParent()
                coins.removeAtIndex(find(coins, coin)!)
            }
        }
    }
    
    func spawnNewStone() {
        
        // create and add a new obstacle
        var rand = CGFloat (CCRANDOM_0_1())
        let stone = CCBReader.load("Stones") as! Stones
        stone.position = ccp(CGFloat(clampf(Float(screenWidth * rand), Float(stone.boundingBox().width), Float(screenWidth - stone.boundingBox().width))), screenHeight + stone.boundingBox().height)
        gamePhysicsNode.addChild(stone)
        stones.append(stone)
        
        //rotate stone
        var rotationSpeed = CGFloat(CCRANDOM_0_1() * 3)
        var rotationDirection: CGFloat = 1
        
        if rand > 0.5 {
            rotationDirection = -1
        }
        
        var impulse = CGFloat(10000.0) * rotationDirection * rotationSpeed
        stone.physicsBody.applyAngularImpulse(CGFloat(impulse))
        stone.animationManager.runAnimationsForSequenceNamed("StoneAnimation")

    }
    
    func removeStone() {
        
        //removes Stones when reach bottom of screen
        for stone in stones.reverse() {
            let stoneWorldPosition = gamePhysicsNode.convertToWorldSpace(stone.position)
            let stoneScreenPosition = convertToNodeSpace(stoneWorldPosition)
            
            if stoneScreenPosition.y < (-stone.boundingBox().height) {
                stone.removeFromParent()
                stones.removeAtIndex(find(stones, stone)!)
            }
        }
    }
    
    

    override func update(delta: CCTime) {
        
        if gameState == .Playing {
            
            xStik = stik.position.x
            
            let pushDirection = CGPoint(x: 1, y: 0)
            
            // so sly dogs can't find equilibrium
            if abs(stik.physicsBody.angularVelocity) < 0.1 {
                if stik.position ==  lastStikPosition {

                    if xStik < screenHalf {
                        stik.physicsBody.applyForce(ccpMult(pushDirection, -100))
                    } else {
                        stik.physicsBody.applyForce(ccpMult(pushDirection, 100))
                    }
                }
            }
            lastStikPosition = stik.position
            //scoring
            score += Float(delta)
            scoreLabel.string = String(Int(score))
            
            gameTimer += Float(delta)
            
            // MARK: difficultyScaling
            if gameLevel == .Begin && Int(gameTimer) == 6 {
  
                //fade out the instruction box
                instruction1.runAction(CCActionFadeOut(duration: 0.5))
                instruction2.runAction(CCActionFadeOut(duration: 0.5))
                
                instructionsVisible = false
                
                for i in 0...2 {
                    spawnNewStone()
                }
                
                gameLevel = .Early

            }
            if gameLevel != .Begin {
                anotherWaveTimer += Float(delta)
                anotherCoinTimer += Float(delta)
            }
            if gameLevel == .Early {
                waveRate = 3
                
                if Int(gameTimer) == 18 {
                    
                    gameLevel = .EarlyMid
                }
            }
            if gameLevel == .EarlyMid {
                waveRate = 2.5
                
                if Int(gameTimer) ==  23{
                    gameLevel = .Mid
                }
            }
            if gameLevel == .Mid {
                waveRate = 2
                
                if Int(gameTimer) == 29 {
                    
                    gameLevel = .LateMid
                }
            }
            if gameLevel == .LateMid {
                waveRate = 1.7
                
                if Int(gameTimer) >= 40 {
                    
                    gameLevel = .Late
                }
            }
            if gameLevel == .Late {
                waveRate = 1.5
                if Int(gameTimer) >=  50 {
                    
                    gameLevel = .VeryLate
                }
            }
            if gameLevel == .VeryLate {
                waveRate = 1.2
                if Int(gameTimer) == 56 {
                    
                    gameLevel = .AlmostGod
                }
            }
            if gameLevel == .AlmostGod {
                
                waveRate = 1
                if Int(gameTimer) == 120 {
                    gameLevel = .God
                }
            }
            if gameLevel == .God {

                waveRate = 0.5
            }
            if anotherWaveTimer >= waveRate {
                
                for i in 0...2 {
                    spawnNewStone()
                }
                
                anotherWaveTimer = 0
            }
            
            if anotherCoinTimer >= 5 {
                spawnNewCoin()
                anotherCoinTimer = 0
            }

            removeStone()
            
            removeCoin()
            
        }
        
        let screenBottom = yBlock
        
        yStik = stik.position.y
        
        // game over
        if yStik < screenBottom {
            let joint = stik.physicsBody.joints
            
            joint.first?.invalidate()
            
            if gameState != .GameOver {
                triggerGameOver()
            }
            
        }
        
        if gameState != .Playing { return }
    }
    
    func triggerGameOver() {
        
        gameState = .GameOver
        
        lastScore = Int(score)
        
        if highScore < Int(score) {
            highScore = Int(score)
            
        }
        
        dropDownLastScore()
        
        //restart()
    }
    
    func attributions() {
        
        attributionScreen = CCBReader.load("Attributions", owner: self) as! Attributions
        self.addChild(attributionScreen)
        self.gameOverScreen.visible = false
        inAttributionScreen = true
        
    }
    
    func returnToGameOver() {
        self.attributionScreen.removeFromParent()
        self.gameOverScreen.visible = true
        inAttributionScreen = false
    }
    
    func restart() {
        
        var mainScene = CCBReader.load("MainScene") as! MainScene
        
        var scene = CCScene()
        scene.addChild(mainScene)
        
        //fades old game out
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }

}

// "%" means modular, Divide by a number and check remainder
