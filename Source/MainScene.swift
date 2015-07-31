import Foundation

enum GameState {
    case Ready, Playing, GameOver
}

enum GameLevel {
    case Begin, Early, EarlyMid, Mid, LateMid, Late, VeryLate, AlmostGod, God
}

class MainScene: CCNode {
    
    weak var stik: CCSprite!
    
    weak var squareblock: CCSprite!
    
    weak var tapRight: CCSprite!
    
    weak var tapLeft: CCSprite!
    
    weak var gamePhysicsNode: CCPhysicsNode!
    
    var pivotJoint: CCPhysicsJoint?
    
    weak var restartButton: CCButton!
    
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
    
    var gameState: GameState = .Ready
    var gameLevel: GameLevel = .Begin
    
    var yStik : CGFloat!   //StiK y pos
    var xStik : CGFloat!    // StiK x pos
    var yBlock : CGFloat! //square block y pos
    
    let screenHalf = CCDirector.sharedDirector().viewSize().width / 2

    var stones : [CCNode] = []
    
    let firstStonePosition : CGFloat = 100
    var lastStikPosition : CGPoint = CGPoint(x: 0 , y: 0)
    
    var anotherWaveTimer: Float = 0
    var waveRate: Float = 3.0
    
    func didLoadFromCCB() {
        
        //gamePhysicsNode.debugDraw = true
        
        userInteractionEnabled = true
        
        yBlock = squareblock.position.y
        
        highScoreLabel.string = String(Int(highScore))
        
        highScore = 0

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
            
            var xForce = CGFloat(1650)     //later do something with trig; tapping low too little force
            //yTouch * 10
            
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
        
        if gameState == .GameOver { return }
    
    }
    
    func spawnNewStone() {
        
        // create and add a new obstacle
        var rand = CGFloat (CCRANDOM_0_1())
        let stone = CCBReader.load("Stones") as! Stones
        let screenHeight = CCDirector.sharedDirector().viewSize().height
        let screenWidth = CCDirector.sharedDirector().viewSize().width
        stone.position = ccp(screenWidth * rand, CGFloat(screenHeight + stone.contentSize.height))
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
            
            // MARK: difficultyScaling
            if gameLevel == .Begin && Int(score) == 6 {
  
                //fade out the instruction box
                instruction1.runAction(CCActionFadeOut(duration: 0.5))
                instruction2.runAction(CCActionFadeOut(duration: 0.5))
                
                for i in 0...2 {
                    spawnNewStone()
                }
                
                gameLevel = .Early

            }
            if gameLevel != .Begin {
                anotherWaveTimer += Float(delta)
            }
            if gameLevel == .Early {
                waveRate = 3
                
                if Int(score) == 18 {
                    gameLevel = .EarlyMid
                }
            }
            if gameLevel == .EarlyMid {
                waveRate = 2.5
                
                if Int(score) ==  23{
                    gameLevel = .Mid
                }
            }
            if gameLevel == .Mid {
                waveRate = 2
                
                if Int(score) == 28 {
                    gameLevel = .LateMid
                }
            }
            if gameLevel == .LateMid {
                waveRate = 1.7
                
                if Int(score) == 40 {
                    gameLevel = .Late
                }
            }
            if gameLevel == .Late {
                waveRate = 1.5
                if Int(score) ==  50 {
                    gameLevel = .VeryLate
                }
            }
            if gameLevel == .VeryLate {
                waveRate = 1.2
                if Int(score) == 56 {
                    gameLevel = .AlmostGod
                }
            }
            if gameLevel == .AlmostGod {
                waveRate = 1
                if Int(score) == 120 {
                    gameLevel = .God
                }
            }
            if gameLevel == .God {
                waveRate = 0.3
            }
            if anotherWaveTimer >= waveRate {
                
                for i in 0...2 {
                    spawnNewStone()
                }
                
                anotherWaveTimer = 0
            }

            // "%" means modular, Divide by a number and check remainder
            
            //removes Stones when reach bottom of screen
            for stone in stones.reverse() {
                let stoneWorldPosition = gamePhysicsNode.convertToWorldSpace(stone.position)
                let stoneScreenPosition = convertToNodeSpace(stoneWorldPosition)
                
                if stoneScreenPosition.y < (-stone.contentSize.height) {
                    stone.removeFromParent()
                    stones.removeAtIndex(find(stones, stone)!)
                }
            }
        }
        
        let screenBottom = yBlock
        
        yStik = stik.position.y
        
        // game over
        if yStik < screenBottom {
            let joint = stik.physicsBody.joints
            
            joint.first?.invalidate()
            
            GameOver()
        }
        
        if gameState != .Playing { return }
    }
    
    func GameOver() {
        
        //restartButton.visible = true
        
        if highScore < Int(score) {
            highScore = Int(score)
            
        }
        
        restart()
        
        return gameState = .GameOver
    }
    
    func restart() {
        
        var mainScene = CCBReader.load("MainScene") as! MainScene
        //mainScene.ready()
        
        var scene = CCScene()
        scene.addChild(mainScene)
        
        //fades old game out
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }

}
