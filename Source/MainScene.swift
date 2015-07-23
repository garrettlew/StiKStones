import Foundation

enum GameState {
    case Ready, Playing, GameOver
}

class MainScene: CCNode {
    
    weak var stik: CCSprite!
    
    weak var squareblock: CCSprite!
    
    weak var tapRight: CCSprite!
    
    weak var tapLeft: CCSprite!
    
    weak var restartButton: CCButton!
    
    weak var gamePhysicsNode: CCPhysicsNode!
    
    weak var scoreLabel: CCLabelTTF!
    var score : Float = 0
    var highScore: Int = NSUserDefaults.standardUserDefaults().integerForKey("myHighScore") ?? 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(highScore, forKey:"myHighScore")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    var pivotJoint: CCPhysicsJoint?
    
    var gameState: GameState = .Ready
    
    var stones : [CCNode] = []
    
    var yStik : CGFloat!   //StiK y pos
    var yBlock : CGFloat! //square block y pos
    
    let firstStonePosition : CGFloat = 100
    
    func didLoadFromCCB() {
        
        //gamePhysicsNode.debugDraw = true
        
        userInteractionEnabled = true
        
        yBlock = squareblock.position.y
        
        //gamePhysicsNode.gravity = CGPoint(x: 0, y: -300)

    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        
        let launchDirection = CGPoint(x: 1, y: 0)
        var screenHalf = CCDirector.sharedDirector().viewSize().width / 2
        let touchLocation = touch.locationInWorld()
        var xTouch = touch.locationInWorld().x
        var yTouch = touch.locationInWorld().y
        
        // so sly dogs cant start the game by tapping above or below the stiK
        if yTouch <= yStik && yTouch >= yBlock && stik.visible {
            if gameState == .Ready {
                
                gameState = .Playing
                
                for i in 0...2 {
                    spawnNewStone()
                }
                
                tapLeft.runAction(CCActionFadeOut(duration: 0.3))
                tapRight.runAction(CCActionFadeOut(duration: 0.3))
                
            }
        }
        
        if gameState == .Playing {
            
            var xForce = pow((yTouch + 3) / 3, 2)     //later do something with trig; tapping low too little force
            
            // tap sides
            if xTouch < screenHalf && yTouch <= yStik {
                stik.physicsBody.applyImpulse(ccpMult(launchDirection, xForce))  //left side
                
                tapLeft.position = touchLocation
                tapLeft.visible = true
                tapLeft.runAction(CCActionFadeOut(duration: 0.3))
            } else if xTouch > screenHalf && yTouch <= yStik {
                stik.physicsBody.applyImpulse(ccpMult(launchDirection, -(xForce)))  //right side
                
                tapRight.position = touchLocation
                tapRight.visible = true
                tapRight.runAction(CCActionFadeOut(duration: 0.3))
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
            
            //scoring
            score += Float(delta)
            scoreLabel.string = String(Int(score))

            for stone in stones.reverse() {
                let stoneWorldPosition = gamePhysicsNode.convertToWorldSpace(stone.position)
                let stoneScreenPosition = convertToNodeSpace(stoneWorldPosition)
                
                // obstacle moved past left side of screen?
                if stoneScreenPosition.y < (-stone.contentSize.height) {
                    stone.removeFromParent()
                    stones.removeAtIndex(find(stones, stone)!)
                    
                    // for each removed obstacle, add a new one
                    spawnNewStone()
                }
            }
        }
        
        let screenBottom = yBlock
        
        yStik = stik.position.y
        
        // game over
        if yStik < screenBottom {
            let joint = stik.physicsBody.joints
            
            joint.first?.invalidate()
            
            triggerGameOver()
        }
        
        if gameState != .Playing { return }
    }
    
    func triggerGameOver() {
        
        restartButton.visible = true
        
        return gameState = .GameOver
    }
    
    func restart() {
        
        var mainScene = CCBReader.load("MainScene") as! MainScene
        //mainScene.ready()
        
        var scene = CCScene()
        scene.addChild(mainScene)
        
        var transition = CCTransition(fadeWithDuration: 0.3)
        
        CCDirector.sharedDirector().presentScene(scene, withTransition: transition)
    }

}
