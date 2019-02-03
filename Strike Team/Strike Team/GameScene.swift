//
//  GameScene.swift
//  Strike Team
//
//  Created by Mike DelGaudio on 1/14/19.
//  Copyright © 2019 Mike DelGaudio. All rights reserved.
//

import SpriteKit
import GameplayKit

//This is public to all other scenes
var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let scoreLabel = SKLabelNode(fontNamed: "Aldo the Apache")
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "Aldo the Apache")
    
    var levelNumber = 0
    
    //this is our player ship; we made it public so that fireBullet sees it
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    let bulletSound = SKAction.playSoundFileNamed("bulletSoundEffect.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("explosionSoundEffect.wav", waitForCompletion: false)
    
    let tapToStartLabel = SKLabelNode(fontNamed: "Aldo the Apache")
    
    enum gameState{
        case preGame    //when the game state is BEFORE the game
        case inGame     //when the game state is DURING
        case afterGame  //when the game state is AFTER the game
    }
    
    var currentGameState = gameState.preGame
    
    struct PhysicsCategories {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 //1
        static let Bullet : UInt32 = 0b10 //2
        static let Enemy : UInt32 = 0b100 //4
    }
    
    //Utility function to make random number
    /*
    func random() -> CGFloat{
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    All this did not work.
    func random(min min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (min - min) + min
    }*/
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    //may need var or let
    var gameArea: CGRect
    //May need to mess with this to make work on iPhone X!
    override init(size: CGSize) {
        //for non-iPhoneX use 16.0/9.0 else 19.5/9.0 for iPhone X; figure this out!
        var maxAspectRatio: CGFloat = 16.0/9.0
        
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436{
                print("iPhone X or other notch")
                maxAspectRatio = 19.5/9.0
            }else if UIScreen.main.nativeBounds.height == 1792{
                print("iPhone XR")
                maxAspectRatio = 19.5/9.0
            }else{
                print("non-iPhone w Notch")
                maxAspectRatio = 16.0/9.0
            }
        }
        
        //let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        //Reset the game score everytime we move back to the gameScene
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0...1{
            //background here is in the assets; also this variable background is being used to
            //center the position of it with the screen (self is the SKScene itself)
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2,
                                          y: self.size.height * CGFloat(i))
            background.zPosition = 0
            background.name = "Background"
            self.addChild(background)
        }
     
        
        //this is our player ship
        //if you want to ship to be bigger change this number
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height) //player starts off screen
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70 //Needs to be bigger and fixed for different iPhones
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        //This can be optimized!!!!
        //Lives Label Not Positioned Correctly
        
        if UIDevice().userInterfaceIdiom == .phone {
            if UIScreen.main.nativeBounds.height >= 2436{
                print("iPhone X or other notch")
                //scoreLabel.position = CGPoint(x: self.size.width * 0.20, y: self.size.height * 0.9)
                scoreLabel.position = CGPoint(x: self.size.width * 0.20, y: self.size.height + scoreLabel.frame.size.height)
                //livesLabel.position = CGPoint(x: self.size.width * 0.80, y: self.size.height * 0.9)
                livesLabel.position = CGPoint(x: self.size.width * 0.80, y: self.size.height + livesLabel.frame.size.height)
            }else if UIScreen.main.nativeBounds.height == 1792{
                print("iPhone XR")
                scoreLabel.position = CGPoint(x: self.size.width * 0.20, y: self.size.height + scoreLabel.frame.size.height)
                //scoreLabel.position = CGPoint(x: self.size.width * 0.20, y: self.size.height * 0.9)
                //livesLabel.position = CGPoint(x: self.size.width * 0.80, y: self.size.height * 0.9)
                livesLabel.position = CGPoint(x: self.size.width * 0.80, y: self.size.height + livesLabel.frame.size.height)
            }else{
                print("non-iPhone w Notch")
                scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height + scoreLabel.frame.size.height)
                //scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.9)
                //livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height * 0.9)
                livesLabel.position = CGPoint(x: self.size.width * 0.80, y: self.size.height + livesLabel.frame.size.height)
            }
        }
        //scoreLabel.position = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.9)//NOT RIGHT IPHONE X!
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        //livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height * 0.9)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        tapToStartLabel.alpha = 0 //the transparency
        self.addChild(tapToStartLabel)
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
    }
    
    //Finding the time between frames of the game; hopefully 58-60fps
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    
    //You should let but you can affect the value of this value to change the pace of the background moving!
    var amountToMovePerSecond: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0{
            lastUpdateTime = currentTime
        }else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background"){
            background, stop in
            
            if self.currentGameState == gameState.inGame{
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height{
                background.position.y += self.size.height * 2
            }
        }
    }
    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOnToScreenAction = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOnToScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    func loseALife(){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0 {
            runGameOver()
        }
        
    }
    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        //How to increase level; so 3 levels with these 3 scores
        if gameScore == 10 || gameScore == 25 || gameScore == 50{
            startNewLevel()
        }
        
    }
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        //This is creating lists of the objects on screen; whether its bullets or enemies and will stop them
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
        }
        
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        //Game will stop; pause for a second; then change scenes
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
            //if the player has hit the enemy
            
            if body1.node != nil {
                spawnExplosion(spawnPosition: body1.node!.position)//change from vid here
            }
            
            if body2.node != nil{
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy{//ep3 says to not add this condition
            //if the bullet has hit the enemy
            addScore()
            
            if body2.node != nil{
                if body2.node!.position.y > self.size.height{
                    return //if the enemy is off the top of the screen, 'return'. This will stop running this code here, therefore doing nothing unless we hit the enemy when it's on the screen. As we are already checking that body2.node isn't nothing, we can safely unwrap (with '!)' this here.
                }else{
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            
            //spawnExplosion(spawnPosition: body2.node!.position)
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
    }
    
    func startNewLevel(){
        
        levelNumber += 1
        
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch levelNumber {
            case 1: levelDuration = 1.2
            case 2: levelDuration = 1
            case 3: levelDuration = 0.8
            case 4: levelDuration = 0.5
            default:
                levelDuration = 0.5
                print("Cannot find level info")
        }
        
        //Think about the sequence here if you want enemies straight away
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    //Makes the bullet in scene
    func fireBullet(){
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"                              //Reference name
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        //This sequence allows these actions to occur in the order we want...
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy(){
        
        //May have to switch the min to max or vise verse
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        //if an enemy makes it to the bottom of the screen, we lose a life
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        //if an enemy spawned offscreen and the game is over this wont run
        if currentGameState == gameState.inGame{
            enemy.run(enemySequence)
        }
        
        //Make enemy image face the right way
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    //MARK: Spawn the bullet on touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if currentGameState == gameState.preGame{
            startGame()
        }else if currentGameState == gameState.inGame{
            fireBullet()
        }
    }
    
    //MARK: How to move the player
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged
            }
            
            // Check if player is in playable area
            // Too far right
            if player.position.x > gameArea.maxX - player.size.width/2 {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            // Too far left
            if player.position.x < gameArea.minX + player.size.width/2 {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
}
