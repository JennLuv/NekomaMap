//
//  DungeonRoomViewModel.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 10/06/24.
//

import Foundation
import SpriteKit
import GameController
import SwiftUI

class DungeonScene2: SKScene, SKPhysicsContactDelegate {
    var idCounter = 1
    var cameraNode: SKCameraNode!
    
    //Game State
    @Binding var isGameOver: Bool
    var isTransitioning = false
    var didMoveCompleted = false
    var savedState: [String: Any] = [:]
    
    //Joystick
    var player: Player2!
    var virtualController: GCVirtualController?
    var playerPosx: CGFloat = 0
    var playerPosy: CGFloat = 0
    
    var lightNode = SKSpriteNode(texture: SKTexture(imageNamed: "light"))
    
    // Movement
    var playerMovedLeft = false
    var playerMovedRight = false
    var playerLooksLeft = false
    var playerLooksRight = true
    
    var playerWalkFrames = [SKTexture]()
    var playerIdleFrames = [SKTexture]()
    var playerAttackFrames = [SKTexture]()
    var playerSalmonFrames = [SKTexture]()
    var playerTunaFrames = [SKTexture]()
    var playerMackarelFrames = [SKTexture]()
    var playerPufferFrames = [SKTexture]()
    
    var lightFrames = [SKTexture]()
    
    var jailUpFrames = [SKTexture]()
    var jailDownFrames = [SKTexture]()
    var jailLeftFrames = [SKTexture]()
    var jailRightFrames = [SKTexture]()
    var jailUpRightFrames = [SKTexture]()
    var jailUpLeftFrames = [SKTexture]()
    var jailDownRightFrames = [SKTexture]()
    var jailDownLeftFrames = [SKTexture]()
    var jailUpDownFrames = [SKTexture]()
    var jailLeftRightFrames = [SKTexture]()
    
    var jailUpFramesReverse = [SKTexture]()
    var jailDownFramesReverse = [SKTexture]()
    var jailLeftFramesReverse = [SKTexture]()
    var jailRightFramesReverse = [SKTexture]()
    var jailUpRightFramesReverse = [SKTexture]()
    var jailUpLeftFramesReverse = [SKTexture]()
    var jailDownRightFramesReverse = [SKTexture]()
    var jailDownLeftFramesReverse = [SKTexture]()
    var jailUpDownFramesReverse = [SKTexture]()
    var jailLeftRightFramesReverse = [SKTexture]()
    
    var lightTextureAtlas = SKTextureAtlas(named: "light")
    
    var jailUpTextureAtlas = SKTextureAtlas(named: "jailUp")
    var jailDownTextureAtlas = SKTextureAtlas(named: "jailDown")
    var jailLeftTextureAtlas = SKTextureAtlas(named: "jailLeft")
    var jailRightTextureAtlas = SKTextureAtlas(named: "jailRight")
    var jailUpRightTextureAtlas = SKTextureAtlas(named: "jailUpRight")
    var jailUpLeftTextureAtlas = SKTextureAtlas(named: "jailUpLeft")
    var jailDownRightTextureAtlas = SKTextureAtlas(named: "jailDownRight")
    var jailDownLeftTextureAtlas = SKTextureAtlas(named: "jailDownLeft")
    var jailUpDownTextureAtlas = SKTextureAtlas(named: "jailUpDown")
    var jailLeftRightTextureAtlas = SKTextureAtlas(named: "jailLeftRight")
    
    var playerWalkTextureAtlas = SKTextureAtlas(named: "playerWalk")
    var playerIdleTextureAtlas = SKTextureAtlas(named: "playerIdle")
    var playerAttackTextureAtlas = SKTextureAtlas(named: "playerAttack")
    var playerSalmonTextureAtlas = SKTextureAtlas(named: "playerSalmon")
    var playerTunaTextureAtlas = SKTextureAtlas(named: "playerTuna")
    var playerMackarelTextureAtlas = SKTextureAtlas(named: "playerMackarel")
    var playerPufferTextureAtlas = SKTextureAtlas(named: "playerPuffer")
    var playerIsMoving = false
    var playerStartMoving = false
    var playerStopMoving = true
    
    //for range weapon animations
    var AK47GunFrames = [SKTexture]()
    var AK47GunTextureAtlas = SKTextureAtlas(named: "ak47GunAnim")
    var BowFrames = [SKTexture]()
    var BowTextureAtlas = SKTextureAtlas(named: "bowAnim")
    var MagicWandFrames = [SKTexture]()
    var MagicWandTextureAtlas = SKTextureAtlas(named: "magicWandAnim")
    var ShurikenFrames = [SKTexture]()
    var ShurikenTextureAtlas = SKTextureAtlas(named: "shurikenAnim")
    
    //for melee weapon animations
    var DarknessKatanaFrames = [SKTexture]()
    var DarknessKatanaTextureAtlas = SKTextureAtlas(named: "darknessKatanaAnim")
    var DarknessScytheFrames = [SKTexture]()
    var DarknessScytheTextureAtlas = SKTextureAtlas(named: "darknessScytheAnim")
    var FireSwordFrames = [SKTexture]()
    var FireSwordTextureAtlas = SKTextureAtlas(named: "fireSwordAnim")
    var WoodAxeFrames = [SKTexture]()
    var WoodAxeTextureAtlas = SKTextureAtlas(named: "woodAxeAnim")
    
    var currentFishPower: String = "salmon"
    
    // Remove Jail
    var shouldRemoveJail = false
    var jailRemovalEnemyName = ""
    
    // Attacks
    var playerIsShooting = false
    var playerIsAttacking = false
    
    // Array
    var enemyManager = [String: Enemy2]()
    
    var weaponSlot: Weapon?
    var weaponSlotButton1: WeaponSlotButton!
    var weaponSlotButton: WeaponSlotButton!
    var weaponSlotButton2: WeaponSlotButton!
    var fishSlot: Fish?
    var fishSlotButton: FishSlotButton!
    
    var hasExecutedIfBlock = false
    
    // Button Cooldown
    var buttonAOnCooldown1 = false
    var buttonAOnCooldown2 = false
    var buttonWeaponSlotCooldown = false
    
    var rooms: [Room]?
    var enemyIsAttacked = false
    
    let tempChest = Chest(id: 0, content: nil)
    var chests: [Chest]?
    var currentChestIndicator: SKSpriteNode?
    var openedChests: [Chest] = []
    
    var enemyCount: Int = 0
    var currentEnemyCount: Int = 0
    
    let buttonZPos = 7
    let lightNodeZPos = 6
    let shootOrMeleeZPos = 4
    let playerZPos = 3
    let enemyZPos = 2
    let weaponSpawnZPos = 1
    let roomZPos = 0
    
    var weaponNow = SKSpriteNode(texture: SKTexture(imageNamed: ""))
    
    var customButton: SKSpriteNode!
    var customButtomPosX = 300
    var customButtomPosY = -100
    
    var buttonAIsPressed: Bool = false
    var weaponSlotButtonIsPressed: Bool = false
    var fishSlotButtonIsPressed: Bool = false
    
    var changeButtonToAlert: Bool = false
    var buttonImageName: String = "buttonAttack"
    
    var currentRoomNum: Int = 0
    var soundManager = SoundManager()
    
    var fishSlotButtonIsInCooldown = false
    var projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: ""))
    init(isGameOver: Binding<Bool>) {
        self._isGameOver = isGameOver
        super.init(size: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        print("DUNGEON SCENE")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Boss
    var bossEnemy: Enemy2?
    var isBossDefeated = false
    var isBossChestSpawned = false
    
    override func didMove(to view: SKView) {
        print("================NEW SCENE===================")
        
        enemyCount = countEnemies()
        let customButton = updateButtonImage()
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        setupCamera()
        
        if lightNode.parent != nil {
            lightNode.removeFromParent()
        }
        
        lightNode.position = CGPoint(x: 0.0, y: 0.0)
        lightNode.zPosition = CGFloat(lightNodeZPos)
        cameraNode.addChild(lightNode)
        
        rooms = generateLevel(roomCount: 8)
        chests = tempChest.generateChests(level: 5)
        drawDungeon(rooms: rooms!, chests: chests!)
        
        scene?.anchorPoint = .zero
        
        
        func atlasInit(textureAtlas: SKTextureAtlas, textureAltasName: String, reverse: Bool = false) -> [SKTexture] {
            var textures = [SKTexture]()
            for i in 0..<textureAtlas.textureNames.count {
                let textureNames = textureAltasName + String(i)
                textures.append(textureAtlas.textureNamed(textureNames))
            }
            if reverse {
                textures.reverse()
            }
            return textures
        }
        playerWalkFrames = atlasInit(textureAtlas: playerWalkTextureAtlas, textureAltasName: "playerWalk")
        playerIdleFrames = atlasInit(textureAtlas: playerIdleTextureAtlas, textureAltasName: "playerIdle")
        playerAttackFrames = atlasInit(textureAtlas: playerAttackTextureAtlas, textureAltasName: "playerAttack")
        playerSalmonFrames = atlasInit(textureAtlas: playerSalmonTextureAtlas, textureAltasName: "playerSalmon")
        playerTunaFrames = atlasInit(textureAtlas: playerTunaTextureAtlas, textureAltasName: "playerTuna")
        playerMackarelFrames = atlasInit(textureAtlas: playerMackarelTextureAtlas, textureAltasName: "playerMackarel")
        playerPufferFrames = atlasInit(textureAtlas: playerPufferTextureAtlas, textureAltasName: "playerPuffer")
        
        lightFrames = atlasInit(textureAtlas: lightTextureAtlas, textureAltasName: "light")
        
        jailUpFrames = atlasInit(textureAtlas: jailUpTextureAtlas, textureAltasName: "jailUp")
        jailDownFrames = atlasInit(textureAtlas: jailDownTextureAtlas, textureAltasName: "jailDown")
        jailLeftFrames = atlasInit(textureAtlas: jailLeftTextureAtlas, textureAltasName: "jailLeft")
        jailRightFrames = atlasInit(textureAtlas: jailRightTextureAtlas, textureAltasName: "jailRight")
        jailUpRightFrames = atlasInit(textureAtlas: jailUpRightTextureAtlas, textureAltasName: "jailUpRight")
        jailUpLeftFrames = atlasInit(textureAtlas: jailUpLeftTextureAtlas, textureAltasName: "jailUpLeft")
        jailDownRightFrames = atlasInit(textureAtlas: jailDownRightTextureAtlas, textureAltasName: "jailDownRight")
        jailDownLeftFrames = atlasInit(textureAtlas: jailDownLeftTextureAtlas, textureAltasName: "jailDownLeft")
        jailUpDownFrames = atlasInit(textureAtlas: jailUpDownTextureAtlas, textureAltasName: "jailUpDown")
        jailLeftRightFrames = atlasInit(textureAtlas: jailLeftRightTextureAtlas, textureAltasName: "jailLeftRight")
        
        jailUpFramesReverse = atlasInit(textureAtlas: jailUpTextureAtlas, textureAltasName: "jailUp", reverse: true)
        jailDownFramesReverse = atlasInit(textureAtlas: jailDownTextureAtlas, textureAltasName: "jailDown", reverse: true)
        jailLeftFramesReverse = atlasInit(textureAtlas: jailLeftTextureAtlas, textureAltasName: "jailLeft", reverse: true)
        jailRightFramesReverse = atlasInit(textureAtlas: jailRightTextureAtlas, textureAltasName: "jailRight", reverse: true)
        jailUpRightFramesReverse = atlasInit(textureAtlas: jailUpRightTextureAtlas, textureAltasName: "jailUpRight", reverse: true)
        jailUpLeftFramesReverse = atlasInit(textureAtlas: jailUpLeftTextureAtlas, textureAltasName: "jailUpLeft", reverse: true)
        jailDownRightFramesReverse = atlasInit(textureAtlas: jailDownRightTextureAtlas, textureAltasName: "jailDownRight", reverse: true)
        jailDownLeftFramesReverse = atlasInit(textureAtlas: jailDownLeftTextureAtlas, textureAltasName: "jailDownLeft", reverse: true)
        jailUpDownFramesReverse = atlasInit(textureAtlas: jailUpDownTextureAtlas, textureAltasName: "jailUpDown", reverse: true)
        jailLeftRightFramesReverse = atlasInit(textureAtlas: jailLeftRightTextureAtlas, textureAltasName: "jailLeftRight", reverse: true)
        
        //for range weapon animations
        AK47GunFrames = atlasInit(textureAtlas: AK47GunTextureAtlas, textureAltasName: "ak47GunAnim", reverse: false)
        BowFrames = atlasInit(textureAtlas: BowTextureAtlas, textureAltasName: "bowAnim", reverse: false)
        MagicWandFrames = atlasInit(textureAtlas: MagicWandTextureAtlas, textureAltasName: "magicWandAnim", reverse: false)
        ShurikenFrames = atlasInit(textureAtlas: ShurikenTextureAtlas, textureAltasName: "shurikenAnim", reverse: false)
        
        DarknessKatanaFrames = atlasInit(textureAtlas: DarknessKatanaTextureAtlas, textureAltasName: "darknessKatanaAnim", reverse: false)
        DarknessScytheFrames = atlasInit(textureAtlas: DarknessScytheTextureAtlas, textureAltasName: "darknessScytheAnim", reverse: false)
        FireSwordFrames = atlasInit(textureAtlas: FireSwordTextureAtlas, textureAltasName: "fireSwordAnim", reverse: false)
        WoodAxeFrames = atlasInit(textureAtlas: WoodAxeTextureAtlas, textureAltasName: "woodAxeAnim", reverse: false)
        
        // Player initial position
        // player = createPlayer(at: CGPoint(x: rooms!.last!.position.x, y: rooms!.last!.position.y))
        player = createPlayer(at: CGPoint(x: 0, y: 0))
        player.zPosition = CGFloat(playerZPos)
        addChild(player)
        
        weaponNow = player.equippedWeapon
        changeAndPlayWeaponNowAnimation()
        
        connectVirtualController()
        
        weaponSlotButton1 = WeaponSlotButton(currentWeapon: player.equippedWeapon)
        let defaultWeapon2 = Weapon(imageName: "AK47Gun", weaponName: "AK47Gun", rarity: .common, projectileName: "AK47GunProj", attack: 2, category: "range")
        weaponSlotButton2 = WeaponSlotButton(currentWeapon: defaultWeapon2)
        
        weaponSlotButton = updateWeaponSlotButton()
        setupFishSlotButton()
        
        cameraNode.addChild(customButton)
        
        soundManager.playSound(fileName: BGM.gameplay, loop: true)
        
        guard !didMoveCompleted else { return }  // Prevent multiple calls
        didMoveCompleted = true
    }
    
    func setupFishSlotButton() {
        fishSlotButton = FishSlotButton(currentFish: player.equippedFish)
        fishSlotButton.position = CGPoint(x: customButtomPosX - 100, y: customButtomPosY - 27)
        fishSlotButton.zPosition = CGFloat(buttonZPos)
        cameraNode.addChild(fishSlotButton)
        
        let radius: CGFloat = 30
        let lineWidth: CGFloat = 7
        let progressColor = UIColor.gray
        
        let progressCircle = createProgressCircle(radius: radius, lineWidth: lineWidth, color: progressColor)
        progressCircle.name = "progressCircle"
        fishSlotButton.addChild(progressCircle)
    }
    
    func createProgressCircle(radius: CGFloat, lineWidth: CGFloat, color: UIColor) -> SKShapeNode {
        let circle = SKShapeNode(circleOfRadius: radius)
        circle.lineWidth = lineWidth
        circle.strokeColor = color
        circle.fillColor = .clear
        circle.zPosition = CGFloat(buttonZPos + 1) // Ensure the progress circle is above the button
        return circle
    }
    
    func updateProgressCircle(_ circle: SKShapeNode, progress: CGFloat) {
        let path = UIBezierPath(arcCenter: .zero, radius: 30, startAngle: -CGFloat.pi / 2, endAngle: (-CGFloat.pi / 2) + (2 * CGFloat.pi * progress), clockwise: true)
        circle.path = path.cgPath
    }
    
    func startFishSlotButtonCooldown() {
        fishSlotButtonIsInCooldown = true
        
        let waitDuration: TimeInterval = 10
        let updateInterval: TimeInterval = 0.1
        
        var elapsedTime: TimeInterval = 0
        
        let updateAction = SKAction.run {
            elapsedTime += updateInterval
            let progress = CGFloat(elapsedTime / waitDuration)
            if let progressCircle = self.fishSlotButton.childNode(withName: "progressCircle") as? SKShapeNode {
                self.updateProgressCircle(progressCircle, progress: progress)
            }
        }
        
        let waitAction = SKAction.wait(forDuration: updateInterval)
        let sequence = SKAction.sequence([updateAction, waitAction])
        let repeatAction = SKAction.repeat(sequence, count: Int(waitDuration / updateInterval))
        
        let cooldownEndAction = SKAction.run {
            self.fishSlotButtonIsPressed = false
            self.fishSlotButtonIsInCooldown = false
            if let progressCircle = self.fishSlotButton.childNode(withName: "progressCircle") as? SKShapeNode {
                self.updateProgressCircle(progressCircle, progress: 1.0)
            }
        }
        
        let finalSequence = SKAction.sequence([repeatAction, cooldownEndAction])
        self.run(finalSequence)
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            // print (location)
            // print (touchedNode)
            
            if touchedNode.name == "customButton" {
                customButtonPressed()
            } else if touchedNode.name == "weaponSlotButton" || touchedNode.name == "weaponTexture" {
                weaponSlotButtonIsPressed = true
                hasExecutedIfBlock = false
            } else if touchedNode.name == "fishSlotButton" || touchedNode.name == "fishTexture" || touchedNode.name == "progressCircle" {
                if !fishSlotButtonIsPressed {
                    fishSlotButtonIsPressed = true
                    
                    switch currentFishPower {
                    case "tuna":
                        player.run(SKAction.animate(with: playerTunaFrames, timePerFrame: 0.1))
                    case "salmon":
                        player.run(SKAction.animate(with: playerSalmonFrames, timePerFrame: 0.1))
                    case "mackarel":
                        player.run(SKAction.animate(with: playerMackarelFrames, timePerFrame: 0.1))
                    case "puffer":
                        player.run(SKAction.animate(with: playerPufferFrames, timePerFrame: 0.1))
                    default:
                        break
                        
                    }
                    
                    // print(fishSlotButtonIsPressed)
                    // print("ispressed")
                    startFishSlotButtonCooldown()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            // print("end")
            // print(fishSlotButtonIsPressed)
            
            if touchedNode.name == "customButton" {
                customButtonReleased()
            } else if touchedNode.name == "weaponSlotButton" || touchedNode.name == "weaponTexture"{
                weaponSlotButtonIsPressed = false
            }
        }
    }
    
    func updateButtonImage() -> SKSpriteNode {
        let buttonImageName = changeButtonToAlert ? "alertButton" : "buttonAttack"
        
        customButton = SKSpriteNode(imageNamed: buttonImageName)
        customButton.position = CGPoint(x: customButtomPosX, y: customButtomPosY)
        customButton.name = "customButton"
        customButton.zPosition = CGFloat(buttonZPos)
        
        return customButton
    }
    
    func changeButtonState(toAlert: Bool) -> SKSpriteNode {
        changeButtonToAlert = toAlert
        let newImage = updateButtonImage()
        return newImage
    }
    
    func customButtonPressed() {
        buttonAIsPressed = true
    }
    
    func customButtonReleased() {
        buttonAIsPressed = false
    }
    
    // MARK: createPlayer
    
    func createPlayer(at position: CGPoint) -> Player2 {
        let player = Player2(hp: 9, imageName: "player", maxHP: 9, name: "Player1", dungeonScene: self)
        player.position = position
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.collisionBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        return player
    }
    
    // MARK: didBegin
    
    func didBegin(_ contact: SKPhysicsContact) {
        let attackFromWeapon = 4;
        // let attackFromWeapon = player.equippedWeapon.attack;
        if contact.bodyB.categoryBitMask == PhysicsCategory.enemy && contact.bodyA.categoryBitMask == PhysicsCategory.projectile {
            
            let enemyCandidate1 = contact.bodyA.node as? Enemy2
            let enemyCandidate2 = contact.bodyB.node as? Enemy2
            
            if enemyCandidate1?.name == nil && enemyCandidate2?.name != nil {
                enemyCandidate2?.takeDamage(attackFromWeapon)
                contact.bodyA.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                let enemyName = contact.bodyB.node?.name
                
                handleProjectileEffect()
                print (projectileEffect)
                projectileEffect.zPosition = 4
                projectileEffect.size = CGSize(width: 10, height: 10)
                contact.bodyB.node?.addChild(projectileEffect)
                
                let wait = SKAction.wait(forDuration: 0.3)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([wait, remove])
                
                projectileEffect.run(sequence)
                
                if enemyCount-3 == currentEnemyCount {
                    handleJailRemoval(enemyName: enemyName!)
                    handleChestSpawn(rooms: rooms!, chests: chests!, enemyName: enemyName!)
                    enemyCount = enemyCount-3
                    return
                }
                
                if !enemyIsAttacked {
                    handleEnemyComparison(enemyName: enemyName!)
                }
                
            } else if enemyCandidate2?.name == nil && enemyCandidate1?.name != nil {
                enemyCandidate1?.takeDamage(attackFromWeapon)
                contact.bodyB.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                let enemyName = contact.bodyA.node?.name
                
                handleProjectileEffect()
                print (projectileEffect)
                projectileEffect.zPosition = 4
                projectileEffect.size = CGSize(width: 10, height: 10)
                contact.bodyA.node?.addChild(projectileEffect)
                
                let wait = SKAction.wait(forDuration: 0.3)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([wait, remove])
                
                projectileEffect.run(sequence)
                
                if enemyCount-3 == currentEnemyCount {
                    handleJailRemoval(enemyName: enemyName!)
                    handleChestSpawn(rooms: rooms!, chests: chests!, enemyName: enemyName!)
                    enemyCount = enemyCount-3
                    return
                }
                
                if !enemyIsAttacked {
                    handleEnemyComparison(enemyName: enemyName!)
                }
            }
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.enemy && contact.bodyB.categoryBitMask == PhysicsCategory.projectile {
            
            let enemyCandidate1 = contact.bodyA.node as? Enemy2
            let enemyCandidate2 = contact.bodyB.node as? Enemy2
            
            if enemyCandidate1?.name == nil && enemyCandidate2?.name != nil {
                enemyCandidate2?.takeDamage(attackFromWeapon)
                contact.bodyA.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                let enemyName = contact.bodyB.node?.name
                
                handleProjectileEffect()
                print (projectileEffect)
                projectileEffect.zPosition = 4
                projectileEffect.size = CGSize(width: 10, height: 10)
                contact.bodyB.node?.addChild(projectileEffect)
                
                let wait = SKAction.wait(forDuration: 0.3)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([wait, remove])
                
                projectileEffect.run(sequence)
                
                if enemyCount-3 == currentEnemyCount {
                    handleJailRemoval(enemyName: enemyName!)
                    handleChestSpawn(rooms: rooms!, chests: chests!, enemyName: enemyName!)
                    enemyCount = enemyCount-3
                    return
                }
                
                if !enemyIsAttacked {
                    handleEnemyComparison(enemyName: enemyName!)
                }
                
            } else if enemyCandidate2?.name == nil && enemyCandidate1?.name != nil{
                enemyCandidate1?.takeDamage(attackFromWeapon)
                contact.bodyB.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                let enemyName = contact.bodyA.node?.name
                
                handleProjectileEffect()
                print (projectileEffect)
                projectileEffect.zPosition = 4
                projectileEffect.size = CGSize(width: 10, height: 10)
                contact.bodyA.node?.addChild(projectileEffect)
                
                let wait = SKAction.wait(forDuration: 0.3)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([wait, remove])
                
                projectileEffect.run(sequence)
                
                if enemyCount-3 == currentEnemyCount {
                    handleJailRemoval(enemyName: enemyName!)
                    handleChestSpawn(rooms: rooms!, chests: chests!, enemyName: enemyName!)
                    print("Chest Spawned")
                    enemyCount = enemyCount-3
                    return
                }
                
                if !enemyIsAttacked {
                    handleEnemyComparison(enemyName: enemyName!)
                    handleEnemyComparison(enemyName: enemyName!)
                }
                
            }
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.enemyProjectile {
            if let playerBody = contact.bodyA.node as? Player2  {
                playerBody.takeDamage(1)
                contact.bodyB.node?.removeFromParent()
            }
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.player && contact.bodyA.categoryBitMask == PhysicsCategory.enemyProjectile {
            if let playerBody = contact.bodyB.node as? Player2  {
                playerBody.takeDamage(1)
                contact.bodyA.node?.removeFromParent()
            }
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.projectile && contact.bodyB.categoryBitMask == PhysicsCategory.target {
            contact.bodyA.node?.removeFromParent()
            
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.projectile && contact.bodyA.categoryBitMask == PhysicsCategory.target {
            contact.bodyB.node?.removeFromParent()
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.wall && contact.bodyB.categoryBitMask == PhysicsCategory.projectile {
            contact.bodyB.node?.removeFromParent()
            
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.wall && contact.bodyA.categoryBitMask == PhysicsCategory.projectile {
            contact.bodyA.node?.removeFromParent()
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.player && contact.bodyB.categoryBitMask == PhysicsCategory.stair {
            if !isTransitioning {
                isTransitioning = true
                DungeonStateManager.shared.saveState(from: self)
                DungeonStateManager.shared.transitionToSpecialRoom(from: self)
            }
            
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.player && contact.bodyA.categoryBitMask == PhysicsCategory.stair {
            if !isTransitioning {
                isTransitioning = true
                DungeonStateManager.shared.saveState(from: self)
                DungeonStateManager.shared.transitionToSpecialRoom(from: self)
            }
        }
    }
    
    func handleProjectileEffect(){
        switch player.equippedWeapon.weaponName {
        case "AK47Gun":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "AK47GunEffect"))
        case "Bow":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "BowEffect"))
        case "DarknessKatana":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "DarknessKatanaEffect"))
        case "DarknessScythe":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "DarknessScytheEffect"))
        case "FireSword":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "FireSwordEffect"))
        case "MagicWand":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "MagicWandEffect"))
        case "Shuriken":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "ShurikenEffect"))
        case "WoodAxe":
            projectileEffect = SKSpriteNode(texture: SKTexture(imageNamed: "WoodAxeEffect"))
        default:
            print ("error")
        }
        
    }
    
    func spawnBoss(in room: Room) {
        guard room == rooms?.last else { return }
        bossEnemy = BossEnemy(name: "Boss")
        if let boss = bossEnemy {
            boss.position = CGPoint(x: room.position.x, y: room.position.y)
            addChild(boss)
        }
    }
    
    func checkBossDefeated() {
        if let boss = bossEnemy, boss.hp < 1 && !isBossChestSpawned {
            isBossDefeated = true
            isBossChestSpawned = true
            // bossEnemy = nil
            handleChestSpawn(rooms: rooms!, chests: chests!, enemyName: "Boss");
        }
    }
    
    func handleChestSpawn(rooms: [Room], chests: [Chest], enemyName: String) {
        
        let roomID = getRoomNumberFromEnemy(enemyName: enemyName)
        
        if let room = rooms.first(where: { $0.id == roomID! + 1 }) {
            if roomID == rooms.last!.id - 1 {
                // Spawn the boss if it hasn't been spawned yet
                if bossEnemy == nil {
                    spawnBoss(in: room)
                }
                // Ensure the chest is spawned only if the boss is defeated
                if isBossDefeated {
                    if let chest = chests.first(where: { $0.id == roomID }) {
                        let chestNode = Chest.createChestNode(at: room.position, room: room.id, content: chest.content)
                        currentChestIndicator = Chest.createChestIndicator(at: chest)
                        addChild(chestNode)
                        addChild(currentChestIndicator!)
                    }
                }
            } else {
                if let chest = chests.first(where: { $0.id == roomID }) {
                    let chestNode = Chest.createChestNode(at: room.position, room: room.id, content: chest.content)
                    let stairNode = spawnStair(at: room.position)
                    currentChestIndicator = Chest.createChestIndicator(at: chest)
                    addChild(chestNode)
                    addChild(stairNode)
                    addChild(currentChestIndicator!)
                }
            }
        }
    }
    
    func spawnStair(at position: CGPoint) -> SKSpriteNode {
        let stair = SKSpriteNode(imageNamed: "stair")
        stair.name = "stair"
        stair.position = CGPoint(x: position.x, y: position.y + 100)
        stair.size = CGSize(width: 50, height: 50)
        stair.physicsBody = SKPhysicsBody(rectangleOf: stair.size)
        stair.physicsBody?.isDynamic = false
        stair.physicsBody?.usesPreciseCollisionDetection = true
        stair.physicsBody?.categoryBitMask = PhysicsCategory.stair
        stair.physicsBody?.collisionBitMask = PhysicsCategory.none
        stair.physicsBody?.contactTestBitMask = PhysicsCategory.player
        return stair
    }
    
    func handleJailRemoval(enemyName: String) {
        shouldRemoveJail = true
        jailRemovalEnemyName = enemyName
        //        removeNodesWithJail(enemyName: enemyName)
        enemyIsAttacked = false
    }
    
    func randomPosition(in room: Room) -> CGPoint {
        // add padding so that enemy won't spawn near jail bar
        let roomPadding:CGFloat = 30
        let minX = room.position.x - (360 / 2 - roomPadding)
        let maxX = room.position.x + (360 / 2 - roomPadding)
        let minY = room.position.y - (360 / 2 - roomPadding)
        let maxY = room.position.y + (360 / 2 - roomPadding)
        
        let randomX = CGFloat.random(in: minX..<maxX)
        let randomY = CGFloat.random(in: minY..<maxY)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    func getRoomNumberFromEnemy(enemyName: String) -> Int? {
        switch enemyName {
        case "Enemy0", "Enemy1", "Enemy2":
            return 1
        case "Enemy3", "Enemy4", "Enemy5":
            return 2
        case "Enemy6", "Enemy7", "Enemy8":
            return 3
        case "Enemy9", "Enemy10", "Enemy11":
            return 4
        case "Enemy12", "Enemy13", "Enemy14":
            return 5
        case "Enemy15", "Enemy16", "Enemy17":
            return 6
        case "Enemy18", "Enemy19", "Enemy20", "Boss": // tha bozz
            return 7
            // case "Enemy21", "Enemy22", "Enemy23":
            //     return 7
            // case "Enemy24", "Enemy25", "Enemy26":
            //     return 8
            // case "Enemy27", "Enemy28", "Enemy29":
            //     return 9
        default:
            return nil
        }
    }
    
    func handleEnemyComparison(enemyName: String) {
        guard let roomNum = getRoomNumberFromEnemy(enemyName: enemyName) else {
            return print("Unknown enemy")
        }
        handleEnemyAttack(roomNum: roomNum, reverse: false)
        currentRoomNum = roomNum
    }
    
    func handleNodeAnimation(enemyName: String) {
        // the jail down here
        handleEnemyAttack(roomNum: currentRoomNum, reverse: true)
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.5) {
            self.removeNodesWithJail(enemyName: enemyName)
        }
        enemyIsAttacked = false
        
        
    }
    
    func removeNodesWithJail(enemyName: String) {
        let jailNodes = children.filter { node in
            return node.physicsBody?.categoryBitMask == PhysicsCategory.wall
        }
        
        let jailDown = false
        
        jailNodes.forEach { jailNode in
            if !jailDown {
                
                guard let roomNum = getRoomNumberFromEnemy(enemyName: enemyName) else {
                    return
                }
                let currentRoom = rooms![roomNum]
                //here
                print("Closing this \(currentRoom.name)")
                
            }
            jailNode.removeFromParent()
            
        }
    }
    
    func getAnimationFrames(for jailName: String, reverse: Bool) -> [SKTexture] {
        switch jailName {
        case "JailUp":
            return reverse ? jailUpFrames.reversed() : jailUpFrames
        case "JailDown":
            return reverse ? jailDownFrames.reversed() : jailDownFrames
        case "JailLeft":
            return reverse ? jailLeftFrames.reversed() : jailLeftFrames
        case "JailRight":
            return reverse ? jailRightFrames.reversed() : jailRightFrames
        case "JailUpDown":
            return reverse ? jailUpDownFrames.reversed() : jailUpDownFrames
        case "JailUpLeft":
            return reverse ? jailUpLeftFrames.reversed() : jailUpLeftFrames
        case "JailUpRight":
            return reverse ? jailUpRightFrames.reversed() : jailUpRightFrames
        case "JailDownLeft":
            return reverse ? jailDownLeftFrames.reversed() : jailDownLeftFrames
        case "JailDownRight":
            return reverse ? jailDownRightFrames.reversed() : jailDownRightFrames
        case "JailLeftRight":
            return reverse ? jailLeftRightFrames.reversed() : jailLeftRightFrames
        default:
            return []
        }
    }
    
    
    func handleEnemyAttack(roomNum: Int, reverse: Bool) {
        let currentRoom = rooms![roomNum]
        let jailNode = SKSpriteNode(imageNamed: currentRoom.getRoomImage().jailName)
        jailNode.position = currentRoom.position
        
        let jailName = currentRoom.getRoomImage().jailName
        // print(jailName)
        
        // Helper function to get the animation frames, reversed if needed
        func getAnimationFrames(for jailName: String, reverse: Bool) -> [SKTexture] {
            switch jailName {
            case "JailUp":
                return reverse ? jailUpFrames.reversed() : jailUpFrames
            case "JailDown":
                return reverse ? jailDownFrames.reversed() : jailDownFrames
            case "JailLeft":
                return reverse ? jailLeftFrames.reversed() : jailLeftFrames
            case "JailRight":
                return reverse ? jailRightFrames.reversed() : jailRightFrames
            case "JailUpDown":
                return reverse ? jailUpDownFrames.reversed() : jailUpDownFrames
            case "JailUpLeft":
                return reverse ? jailUpLeftFrames.reversed() : jailUpLeftFrames
            case "JailUpRight":
                return reverse ? jailUpRightFrames.reversed() : jailUpRightFrames
            case "JailDownLeft":
                return reverse ? jailDownLeftFrames.reversed() : jailDownLeftFrames
            case "JailDownRight":
                return reverse ? jailDownRightFrames.reversed() : jailDownRightFrames
            case "JailLeftRight":
                return reverse ? jailLeftRightFrames.reversed() : jailLeftRightFrames
            default:
                return []
            }
        }
        
        // Get the appropriate animation frames
        let frames = getAnimationFrames(for: jailName, reverse: reverse)
        
        soundManager.playSound(fileName: PrisonSFX.prison, volume: 0.25)
        
        // Run the animation
        if !frames.isEmpty {
            jailNode.run(SKAction.animate(with: frames, timePerFrame: 1))
            print(jailName.lowercased())
        }
        
        let jailExtraNode = SKSpriteNode(imageNamed: currentRoom.getRoomImage().jailExtraName)
        jailExtraNode.position = currentRoom.position
        
        jailNode.physicsBody = SKPhysicsBody(texture: jailNode.texture!, size: roomGridSize)
        jailNode.physicsBody?.isDynamic = false
        jailNode.physicsBody?.usesPreciseCollisionDetection = true
        jailNode.physicsBody?.categoryBitMask = PhysicsCategory.wall
        jailNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        jailExtraNode.physicsBody = SKPhysicsBody(texture: jailExtraNode.texture!, size: roomGridSize)
        jailExtraNode.physicsBody?.isDynamic = false
        jailExtraNode.physicsBody?.usesPreciseCollisionDetection = true
        jailExtraNode.physicsBody?.categoryBitMask = PhysicsCategory.wall
        jailExtraNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        jailNode.zPosition = CGFloat(roomZPos + 1)
        jailExtraNode.zPosition = CGFloat(roomZPos)
        
        addChild(jailExtraNode)
        addChild(jailNode)
        enemyIsAttacked = true
    }
    
    
    
    
    func countEnemies() -> Int {
        let enemyNodes = children.filter { node in
            return node.name?.contains("Enemy") ?? false
        }
        return enemyNodes.count
    }
    
    //erase
    func handleEnemyAttack(roomNum: Int) {
        let currentRoom = rooms![roomNum]
        let jailNode = SKSpriteNode(imageNamed: currentRoom.getRoomImage().jailName)
        jailNode.position = currentRoom.position
        
        //here
        let jailName = currentRoom.getRoomImage().jailName
        print (jailName)
        soundManager.playSound(fileName: PrisonSFX.prison)
        switch jailName {
        case "JailUp":
            jailNode.run(SKAction.animate(with: jailUpFrames, timePerFrame: 0.5))
            print("jailUp")
        case "JailDown":
            jailNode.run(SKAction.animate(with: jailDownFrames, timePerFrame: 0.5))
            print("jailDown")
        case "JailLeft":
            jailNode.run(SKAction.animate(with: jailLeftFrames, timePerFrame: 0.5))
            print("jailLeft")
        case "JailRight":
            jailNode.run(SKAction.animate(with: jailRightFrames, timePerFrame: 0.5))
            print("jailRight")
        case "JailUpDown":
            jailNode.run(SKAction.animate(with: jailUpDownFrames, timePerFrame: 0.5))
            print("jailUpDown")
        case "JailUpLeft":
            jailNode.run(SKAction.animate(with: jailUpLeftFrames, timePerFrame: 0.5))
            print("jailUpLeft")
        case "JailUpRight":
            jailNode.run(SKAction.animate(with: jailUpRightFrames, timePerFrame: 0.5))
            print("jailUpRight")
        case "JailDownLeft":
            jailNode.run(SKAction.animate(with: jailDownLeftFrames, timePerFrame: 0.5))
            print("jailDownLeft")
        case "JailDownRight":
            jailNode.run(SKAction.animate(with: jailDownRightFrames, timePerFrame: 0.5))
            print("jailDownRight")
        case "JailLeftRight":
            jailNode.run(SKAction.animate(with: jailLeftRightFrames, timePerFrame: 0.5))
            print("jailLeftRight")
        default:
            print ("")
        }
        
        let jailExtraNode = SKSpriteNode(imageNamed: currentRoom.getRoomImage().jailExtraName)
        jailExtraNode.position = currentRoom.position
        
        jailNode.physicsBody = SKPhysicsBody(texture: jailNode.texture!, size: roomGridSize)
        jailNode.physicsBody?.isDynamic = false
        jailNode.physicsBody?.usesPreciseCollisionDetection = true
        jailNode.physicsBody?.categoryBitMask = PhysicsCategory.wall
        jailNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        jailExtraNode.physicsBody = SKPhysicsBody(texture: jailExtraNode.texture!, size: roomGridSize)
        jailExtraNode.physicsBody?.isDynamic = false
        jailExtraNode.physicsBody?.usesPreciseCollisionDetection = true
        jailExtraNode.physicsBody?.categoryBitMask = PhysicsCategory.wall
        jailExtraNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        
        jailNode.zPosition = CGFloat(roomZPos + 1)
        jailExtraNode.zPosition = CGFloat(roomZPos)
        addChild(jailExtraNode)
        addChild(jailNode)
        enemyIsAttacked = true
    }
    
    
    // MARK: for weaponSlot
    func updateWeaponSlotButton() -> WeaponSlotButton {
        
        if weaponSlotButton == nil {
            weaponSlotButton = weaponSlotButton1
        } else if weaponSlotButton == weaponSlotButton1 {
            weaponSlotButton = weaponSlotButton2
        } else if weaponSlotButton == weaponSlotButton2 {
            weaponSlotButton = weaponSlotButton1
        }
        
        weaponSlotButton.position = CGPoint(x: customButtomPosX + 27, y: customButtomPosY + 100)
        weaponSlotButton.zPosition = CGFloat(buttonZPos)
        weaponSlotButton.name = "weaponSlotButton"
        
        return weaponSlotButton
    }
    //end
    
    // MARK: Update
    func changeAndPlayWeaponNowAnimation() {
        weaponNow.removeFromParent()
        weaponNow = player.equippedWeapon
        weaponNow.size = CGSize(width: 60, height: 60)
        weaponNow.position = CGPoint(x: -10, y: 30)
        weaponNow.zRotation = CGFloat(-30 * Double.pi / 180)
        player.addChild(weaponNow)
        
        let moveUp = SKAction.moveBy(x: 0, y: 7, duration: 0.5)
        let moveDown = SKAction.moveBy(x: 0, y: -7, duration: 0.5)
        let sequence = SKAction.sequence([moveUp, moveDown])
        let repeatForever = SKAction.repeatForever(sequence)
        
        weaponNow.run(repeatForever)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if shouldRemoveJail {
            handleNodeAnimation(enemyName: jailRemovalEnemyName)
            shouldRemoveJail = false
        }
        
        if saveFishToSlotWhenNear() != nil || saveWeaponToSlotWhenNear() != nil{
            customButton.removeFromParent()
            customButton = changeButtonState(toAlert: true)
            cameraNode.addChild(customButton)
        } else {
            customButton.removeFromParent()
            customButton = changeButtonState(toAlert: false)
            cameraNode.addChild(customButton)
        }
        
        if weaponSlotButtonIsPressed == true && hasExecutedIfBlock == false {
            soundManager.playSound(fileName: ButtonSFX.swapWeapon, volume: 0.6)
            weaponSlotButton.removeFromParent()
            weaponSlotButton = updateWeaponSlotButton()
            player.equippedWeapon = weaponSlotButton._currentWeapon
            cameraNode.addChild(weaponSlotButton)
            player.removeAllChildren()
            changeAndPlayWeaponNowAnimation()
            hasExecutedIfBlock = true
        } else if weaponSlotButtonIsPressed == false && hasExecutedIfBlock == false {
            soundManager.playSound(fileName: ButtonSFX.swapWeapon, volume: 0.6)
            weaponSlotButton.removeFromParent()
            weaponSlotButton = updateWeaponSlotButton()
            player.equippedWeapon = weaponSlotButton._currentWeapon
            cameraNode.addChild(weaponSlotButton)
            player.removeAllChildren()
            changeAndPlayWeaponNowAnimation()
            hasExecutedIfBlock = true
        }
        
        
        if let thumbstick = virtualController?.controller?.extendedGamepad?.leftThumbstick {
            let playerPosx = CGFloat(thumbstick.xAxis.value)
            let playerPosy = CGFloat(thumbstick.yAxis.value)
            
            let movementSpeed: CGFloat = 3.0
            
            player.physicsBody?.velocity = CGVector(dx: playerPosx * movementSpeed * 60, dy: playerPosy * movementSpeed * 60)
            player.physicsBody?.allowsRotation = false
            
            if let v = player.physicsBody?.velocity {
                if v == CGVector(dx:0, dy:0) {
                    if playerIsMoving == true {
                        playerStopMoving = true
                    }
                    playerIsMoving = false
                } else {
                    if playerIsMoving == false {
                        playerStartMoving = true
                    }
                    playerIsMoving = true
                }
            }
            
            if playerStartMoving {
                // soundManager.playSound(fileName: PlayerSFX.playerWalking, volume: 1.0, loop: true)
                playerStartMoving = false
                player.removeAllActions()
                player.run(SKAction.repeatForever(SKAction.animate(with: playerWalkFrames, timePerFrame: 0.1)))
                lightNode.run(SKAction.repeatForever(SKAction.animate(with: lightFrames, timePerFrame: 0.5)))
            }
            if playerStopMoving {
                // soundManager.stopSound(fileName: PlayerSFX.playerWalking)
                playerStopMoving = false
                player.removeAllActions()
                player.run(SKAction.repeatForever(SKAction.animate(with: playerIdleFrames, timePerFrame: 0.2)))
                lightNode.run(SKAction.repeatForever(SKAction.animate(with: lightFrames, timePerFrame: 0.5)))
            }
            
            if playerPosx > 0 {
                playerMovedRight = true
            } else {
                playerMovedRight = false
            }
            
            if playerPosx < 0 {
                playerMovedLeft = true
            } else {
                playerMovedLeft = false
            }
            
            if playerMovedLeft == true && playerLooksRight == true {
                player.xScale = -player.xScale
                playerLooksRight = false
                playerLooksLeft = true
            }
            
            if playerMovedRight == true && playerLooksLeft == true {
                player.xScale = -player.xScale
                playerLooksLeft = false
                playerLooksRight = true
            }
            
            cameraNode.position = player.position
            updateChestIndicator()
            
        }
        
        if buttonAIsPressed {
            // Add a global buttonA cooldown, preventing any spam function calls
            if buttonAOnCooldown1 || buttonAOnCooldown2 {
                return
            }
            buttonAOnCooldown1 = true
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
                self.buttonAOnCooldown1 = false
            }
            
            // If nearby weapon, then A button should swap weapon
            if let weapon = saveWeaponToSlotWhenNear(), saveWeaponToSlotWhenNear() != nil {
                soundManager.playSound(fileName: ChestSFX.itemPickUp, volume: 0.8)
                // TODO: refactor placing weapon on map
                let weaponSpawn2 = Weapon(imageName: player.equippedWeapon.weaponName, weaponName: player.equippedWeapon.weaponName, rarity: player.equippedWeapon.rarity, projectileName: player.equippedWeapon.projectileName, attack: player.equippedWeapon.attack, category: player.equippedWeapon.category)
                weaponSpawn2.position = CGPoint(x: weapon.position.x, y: weapon.position.y)
                let originalSize2 = weaponSpawn2.size
                weaponSpawn2.size = CGSize(width: originalSize2.width / 2, height: originalSize2.height / 2)
                
                // Let's put a function below player picking up the weapon
                weaponSlotButton.updateTexture(with: weaponSlot)
                player.equippedWeapon = weapon
                buttonAOnCooldown2 = true
                
                // Replace the picked up weapon from map
                weapon.removeFromParent()
                weaponSpawn2.zPosition = CGFloat(weaponSpawnZPos)
                addChild(weaponSpawn2)
                
                // Set cooldown so that no surprise attack when picking up weapon
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    self.buttonAOnCooldown2 = false
                }
                player.removeAllChildren()
                changeAndPlayWeaponNowAnimation()
                return
            }
            
            if let fish = saveFishToSlotWhenNear(), saveFishToSlotWhenNear() != nil {
                soundManager.playSound(fileName: ButtonSFX.swapFish)
                // TODO: refactor placing weapon on map
                
                fishSlotButton.updateTexture(with: fishSlot)
                let fishName = fishSlot!.fishName
                switch fishName {
                case "tunaCommon", "tunaUncommon", "tunaRare":
                    player.run(SKAction.animate(with: playerTunaFrames, timePerFrame: 0.1))
                    currentFishPower = "tuna"
                case "salmonCommon", "salmonUncommon", "salmonRare":
                    player.run(SKAction.animate(with: playerSalmonFrames, timePerFrame: 0.1))
                    currentFishPower = "salmon"
                case "mackarelCommon", "mackarelUncommon", "mackarelRare":
                    player.run(SKAction.animate(with: playerMackarelFrames, timePerFrame: 0.1))
                    currentFishPower = "mackarel"
                case "pufferCommon", "pufferUncommon", "pufferRare":
                    player.run(SKAction.animate(with: playerPufferFrames, timePerFrame: 0.1))
                    currentFishPower = "puffer"
                default:
                    break
                }
                
                player.equippedFish = fish
                buttonAOnCooldown2 = true
                
                // Replace the picked up weapon from map
                fish.removeFromParent()
                
                // Set cooldown so that no surprise attack when picking up weapon
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    self.buttonAOnCooldown2 = false
                }
                return
            }
            
            if player.equippedWeapon.category == "melee" {
                meleeAttack()
            } else {
                shootImage()
            }
            isPlayerCloseToChest()
        }
        checkBossDefeated()
        
        for enemyPair in enemyManager {
            //            let enemyName = enemyPair.key
            let enemy = enemyPair.value
            let distance = hypotf(Float(enemy.position.x - player.position.x), Float(enemy.position.y - player.position.y))
            if distance < 150 {
                if enemy.hp > 0 {
                    enemy.chasePlayer(player: player)
                    if let rangedEnemy = enemy as? RangedEnemy {
                        rangedEnemy.shootBullet(player: player, scene: self)
                    }
                }
            }
        }
        
    }

    func isPlayerCloseToChest() {
        let range: CGFloat = 40.0
        let targetNodes = children.filter { node in
            return node is Chest
        }
        for child in targetNodes {
            if let chest = child as? Chest, !chest.isOpened {
                let distance = hypot(player.position.x - chest.position.x, player.position.y - chest.position.y)
                if distance <= range && !openedChests.contains(where: { $0.id == chest.id }){
                    currentChestIndicator?.removeFromParent()
                    currentChestIndicator = nil
                    soundManager.playSound(fileName: ChestSFX.chestOpened)
                    Chest.changeTextureToOpened(chestNode: chest)
                    if chest.content == nil {
                        chest.run(Chest.createChestNormalVoidAnimation())
                    } else {
                        chest.spawnContent()
                    }
                    openedChests.append(chest)
                }
            }
        }
    }
    
    func updateChestIndicator() {
        let range: CGFloat = 50.0
        var isIndicatorShown = false
        let targetNodes = children.filter { node in
            return node is Chest
        }
        for child in targetNodes {
            if let chest = child as? Chest, !chest.isOpened {  // Check if the chest is not opened
                let distance = hypot(player.position.x - chest.position.x, player.position.y - chest.position.y)
                if distance <= range {
                    if currentChestIndicator == nil {
                        currentChestIndicator = Chest.createChestIndicator(at: chest)
                        addChild(currentChestIndicator!)
                    }
                    isIndicatorShown = true
                    break
                }
            }
        }
        
        if !isIndicatorShown && currentChestIndicator != nil {
            currentChestIndicator?.removeFromParent()
            currentChestIndicator = nil
        }
    }
    
    func isPlayerCloseToEnemy() -> Bool {
        let weaponRange: CGFloat = 50.0
        let enemyNodes = children.filter { node in
            guard let spriteNode = node as? SKSpriteNode else { return false }
            return spriteNode.physicsBody?.categoryBitMask == PhysicsCategory.enemy
        }
        for node in enemyNodes {
            if let enemy = node as? SKSpriteNode {
                let enemyPosition = enemy.position
                let distance = hypot(player.position.x - enemyPosition.x, player.position.y - enemyPosition.y)
                if distance <= weaponRange {
                    return true
                }
            }
        }
        return false
    }
    
    
    func saveWeaponToSlotWhenNear() -> Weapon? {
        let range: CGFloat = 50.0
        let targetNodes = children.filter { node in
            return node is Weapon
        }
        for child in targetNodes {
            if let weapon = child as? Weapon {
                let distance = hypot(player.position.x - weapon.position.x, player.position.y - weapon.position.y)
                if distance <= range {
                    weaponSlot = weapon
                    return weapon
                }
            }
        }
        return nil
    }
    
    func saveFishToSlotWhenNear() -> Fish? {
        let range: CGFloat = 50.0
        let targetNodes = children.filter { node in
            return node is Fish
        }
        for child in targetNodes {
            if let fish = child as? Fish {
                let distance = hypot(player.position.x - fish.position.x, player.position.y - fish.position.y)
                if distance <= range {
                    fishSlot = fish
                    return fish
                }
            }
        }
        return nil
    }
    
    
    // MARK: meleeAttack
    
    func meleeAttack() {
        if playerIsAttacking {
            return
        }
        playerIsAttacking = true
        
        let attackSpeed = 0.8
        let weaponRange = 2
        
        player.run(SKAction.animate(with: playerAttackFrames, timePerFrame: 0.1))
        
        var direction = 1
        if playerLooksLeft {
            direction = -1
        }
        
        soundManager.playSound(fileName: WeaponSFX.swordKatanaScythe)
        
        let hitbox = SKSpriteNode(imageNamed: player.equippedWeapon.projectileName)
        hitbox.xScale = CGFloat(direction)
        hitbox.position = CGPoint(x: player.position.x + CGFloat(30 * direction), y: player.position.y)
        hitbox.size = CGSize(width: 36 * weaponRange, height: 36 * weaponRange)
        hitbox.physicsBody = SKPhysicsBody(rectangleOf: hitbox.size)
        hitbox.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        hitbox.physicsBody?.collisionBitMask = PhysicsCategory.none
        hitbox.physicsBody?.contactTestBitMask = PhysicsCategory.target
        hitbox.physicsBody?.affectedByGravity = false
        
        let hitboxImage = SKSpriteNode(imageNamed: player.equippedWeapon.weaponName)
        hitboxImage.xScale = CGFloat(direction)
        hitboxImage.position = CGPoint(x: player.position.x + CGFloat(30 * direction), y: player.position.y)
        hitboxImage.size = CGSize(width: 36 * weaponRange, height: 36 * weaponRange)
        
        
        hitbox.zPosition = CGFloat(shootOrMeleeZPos)
        hitboxImage.zPosition = CGFloat(shootOrMeleeZPos)
        hitbox.alpha = 0
        self.addChild(hitbox)
        self.addChild(hitboxImage)
        
        switch player.equippedWeapon.weaponName {
        case "DarknessKatana":
            hitboxImage.run(SKAction.animate(with: DarknessKatanaFrames, timePerFrame: 0.05))
        case "DarknessScythe":
            hitboxImage.run(SKAction.animate(with: DarknessScytheFrames, timePerFrame: 0.05))
        case "FireSword":
            hitboxImage.run(SKAction.animate(with: FireSwordFrames, timePerFrame: 0.05))
        case "WoodAxe":
            hitboxImage.run(SKAction.animate(with: WoodAxeFrames, timePerFrame: 0.05))
        default:
            print("error")
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            hitbox.removeFromParent()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            hitboxImage.removeFromParent()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + attackSpeed) {
            self.playerIsAttacking = false
        }
    }
    
    // MARK: ShootImage
    
    func shootImage() {
        if playerIsShooting {
            return
        }
        playerIsShooting = true
        
        //edithere
        switch player.equippedWeapon.weaponName {
        case "AK47Gun":
            player.equippedWeapon.run(SKAction.animate(with: AK47GunFrames, timePerFrame: 0.1))
        case "Bow":
            player.equippedWeapon.run(SKAction.animate(with: BowFrames, timePerFrame: 0.1))
        case "MagicWand":
            player.equippedWeapon.run(SKAction.animate(with: MagicWandFrames, timePerFrame: 0.1))
        case "Shuriken":
            player.equippedWeapon.run(SKAction.animate(with: ShurikenFrames, timePerFrame: 0.1))
        default:
            print("error")
        }
        
        let attackSpeed = 1.0
        let projectileSpeed = 400
        
        player.run(SKAction.animate(with: playerAttackFrames, timePerFrame: 0.1))
        
        var direction = 1
        if playerLooksLeft {
            direction = -1
        }
        
        soundManager.playSound(fileName: WeaponSFX.arrow)
        
        let projectile = SKSpriteNode(imageNamed: player.equippedWeapon.projectileName)
        projectile.position = player.position
        projectile.size = CGSize(width: 20, height: 20)
        projectile.physicsBody = SKPhysicsBody(rectangleOf: projectile.size)
        projectile.physicsBody?.velocity = CGVector(dx: direction * projectileSpeed, dy: 0)
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.target
        projectile.physicsBody?.affectedByGravity = false
        
        projectile.zPosition = CGFloat(shootOrMeleeZPos)
        self.addChild(projectile)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            projectile.removeFromParent()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + attackSpeed) {
            self.playerIsShooting = false
        }
    }
    
    
    // MARK: connectVirtualController
    
    func connectVirtualController() {
        let controllerConfig = GCVirtualController.Configuration()
        controllerConfig.elements = [GCInputLeftThumbstick]
        
        virtualController = GCVirtualController(configuration: controllerConfig)
        virtualController?.connect()
    }
    
    
    // MARK: setupCamera
    
    func setupCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        cameraNode.setScale(0.7)
        addChild(cameraNode)
    }
    
    // MARK: drawDungeon
    
    func drawDungeon(rooms: [Room], chests: [Chest]) {
        
        for room in rooms {
            let roomNode = SKSpriteNode(imageNamed: room.getRoomImage().imageName)
            roomNode.position = room.position
            
            // For Bg
            let roomBgNode = SKSpriteNode(imageNamed: room.getRoomImage().bgName)
            roomBgNode.position = room.position
            
            let roomExtraNode = SKSpriteNode(imageNamed: room.getRoomImage().imageExtraName)
            roomExtraNode.position = room.position
            
            
            // Set up the physics body based on the room image
            roomNode.physicsBody = SKPhysicsBody(texture: roomNode.texture!, size: roomNode.size)
            roomNode.physicsBody?.isDynamic = false
            roomNode.physicsBody?.usesPreciseCollisionDetection = true
            roomNode.physicsBody?.categoryBitMask = PhysicsCategory.target
            roomNode.physicsBody?.collisionBitMask = PhysicsCategory.target
            roomNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
            
            //for extra image
            // Set up the physics body based on the room image
            roomExtraNode.physicsBody = SKPhysicsBody(texture: roomExtraNode.texture!, size: roomExtraNode.size)
            roomExtraNode.physicsBody?.isDynamic = false
            roomExtraNode.physicsBody?.usesPreciseCollisionDetection = true
            roomExtraNode.physicsBody?.categoryBitMask = PhysicsCategory.target
            roomExtraNode.physicsBody?.collisionBitMask = PhysicsCategory.target
            roomExtraNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
            
            
            roomBgNode.zPosition = CGFloat(roomZPos)
            roomNode.zPosition = CGFloat(roomZPos)
            roomExtraNode.zPosition = CGFloat(roomZPos)
            addChild(roomBgNode)
            addChild(roomNode)
            addChild(roomExtraNode)
            
            //            let fishSpawn = Fish(imageName: "tunaCommon", fishName: "tunaCommon")
            //            fishSpawn.position = CGPoint(x: room.position.x, y: room.position.y - 70)
            //            let originalSize4 = fishSpawn.size
            //            fishSpawn.size = CGSize(width: originalSize4.width / 2, height: originalSize4.height / 2)
            //
            //            let fishSpawn2 = Fish(imageName: "pufferCommon", fishName: "pufferCommon")
            //            fishSpawn2.position = CGPoint(x: room.position.x + 5, y: room.position.y - 10)
            //            let originalSize3 = fishSpawn2.size
            //            fishSpawn2.size = CGSize(width: originalSize3.width / 2, height: originalSize3.height / 2)
            //
            //            let weaponSpawn = Weapon(imageName: "cherryBomb", weaponName: "cherryBomb")
            //            weaponSpawn.position = CGPoint(x: room.position.x, y: room.position.y - 100)
            //            let originalSize = weaponSpawn.size
            //            weaponSpawn.size = CGSize(width: originalSize.width / 2, height: originalSize.height / 2)
            //
            //            let weaponSpawn2 = Weapon(imageName: "yarnBall", weaponName: "yarnBall")
            //            weaponSpawn2.position = CGPoint(x: room.position.x + 50, y: room.position.y + 170)
            //            let originalSize2 = weaponSpawn2.size
            //            weaponSpawn2.size = CGSize(width: originalSize2.width / 2, height: originalSize2.height / 2)
            //
            //            weaponSpawn.zPosition = CGFloat(weaponSpawnZPos)
            //            weaponSpawn2.zPosition = CGFloat(weaponSpawnZPos)
            
            if room != rooms.first {
                for _ in 0..<Int.random(in: 1...1) {
                    let enemy = createEnemy(at: randomPosition(in: room), variant: "Ranged")
                    addChild(enemy)
                }
                for _ in 0..<Int.random(in: 2...2) {
                    let enemy = createEnemy(at: randomPosition(in: room), variant: "Melee")
                    addChild(enemy)
                }
            }
        }
    }
    
    // MARK: createEnemy
    
    func createEnemy(at position: CGPoint, variant: String) -> Enemy2 {
        let enemy: Enemy2
        if (variant == "Ranged") {
            enemy = RangedEnemy(name: "Enemy\(enemyCount)")
        } else {
            enemy = MeleeEnemy(name:"Enemy\(enemyCount)")
        }
        enemy.position = position
        enemy.name = "Enemy\(enemyCount)"
        enemyCount += 1
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        enemy.zPosition = CGFloat(enemyZPos)
        
        enemyManager[enemy.name!] = enemy
        return enemy
    }
    
    // MARK: drawSpecialDungeon
    
    func drawSpecialDungeon() {
        let roomSpecialNode = SKSpriteNode(imageNamed: "RoomSpecial")
        roomSpecialNode.position = CGPoint(x: 0, y: 0)
        
        let roomExtraSpecialNode = SKSpriteNode(imageNamed: "RoomExtraSpecial")
        roomExtraSpecialNode.position = CGPoint(x: 0, y: 0)
        
        let BgSpecialNode = SKSpriteNode(imageNamed: "BgSpecial")
        BgSpecialNode.position = CGPoint(x: 0, y: 0)
        
        roomSpecialNode.physicsBody = SKPhysicsBody(texture: roomSpecialNode.texture!, size: roomGridSize)
        roomSpecialNode.physicsBody?.isDynamic = false
        roomSpecialNode.physicsBody?.usesPreciseCollisionDetection = true
        roomSpecialNode.physicsBody?.categoryBitMask = PhysicsCategory.target
        roomSpecialNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        roomExtraSpecialNode.physicsBody = SKPhysicsBody(texture: roomExtraSpecialNode.texture!, size: roomGridSize)
        roomExtraSpecialNode.physicsBody?.isDynamic = false
        roomExtraSpecialNode.physicsBody?.usesPreciseCollisionDetection = true
        roomExtraSpecialNode.physicsBody?.categoryBitMask = PhysicsCategory.target
        roomExtraSpecialNode.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        
        BgSpecialNode.zPosition = CGFloat(roomZPos)
        roomExtraSpecialNode.zPosition = CGFloat(roomZPos)
        roomSpecialNode.zPosition = CGFloat(roomZPos)
        addChild(BgSpecialNode)
        addChild(roomExtraSpecialNode)
        addChild(roomSpecialNode)
    }
    
    // MARK: getOpposite Direction
    
    func getOppositeDirection(from direction: Direction) -> Direction {
        switch direction {
        case .Up:
            return .Down
        case .Down:
            return .Up
        case .Left:
            return .Right
        case .Right:
            return .Left
        }
    }
    
    // MARK: randomizeNextDirection
    
    func randomizeNextDirections(currentPosition: CGPoint, positionTaken: [PairInt: Bool], from: Direction, branch: Int ) -> [Direction] {
        var nextRoom: [Direction] = []
        
        var branches:[Direction] = [from]
        
        for _ in 0..<branch {
            var nextBranches = allDirection
            nextBranches = nextBranches.filter { !branches.contains($0!) }
            
            // let's also check whether the next branch's grid has been taken
            nextBranches = nextBranches.filter({
                switch $0 {
                case .Left:
                    return !(positionTaken[PairInt(first: Int(currentPosition.x - roomGridSize.width), second: Int(currentPosition.y))] ?? false)
                case .Right:
                    return !(positionTaken[PairInt(first: Int(currentPosition.x + roomGridSize.width), second: Int(currentPosition.y))] ?? false)
                case .Up:
                    return !(positionTaken[PairInt(first: Int(currentPosition.x), second: Int(currentPosition.y + roomGridSize.height))] ?? false)
                case .Down:
                    return !(positionTaken[PairInt(first: Int(currentPosition.x), second: Int(currentPosition.y - roomGridSize.height))] ?? false)
                case .none:
                    return false
                }
            })
            
            let nextBranch = (nextBranches.randomElement() ?? Direction(rawValue: "Up"))!
            branches.append(nextBranch)
            nextRoom.append(nextBranch)
        }
        
        return nextRoom
    }
    
    // MARK: generateLevel
    
    func generateLevel(roomCount: Int, catAppearance: Int? = nil) -> [Room] {
        // Grid Map
        var positionTaken: [PairInt: Bool] = [:]
        
        //        print("Generate level invoked")
        // Generate First Room
        let nextDirection = allDirection.randomElement()!
        let firstRoom = Room(id: idCounter, from: 0, toDirection: [nextDirection!], position: CGPoint(x: 0, y: 0))
        positionTaken[PairInt(first: 0, second: 0)] = true
        idCounter += 1
        
        var rooms = [firstRoom]
        var currentRoom = firstRoom
        
        for i in 2...roomCount {
            let nextDirections = currentRoom.toDirection
            // let's take one of the directions to make a room
            let nextDirection = nextDirections!.randomElement()
            // the next room is from the opposite
            let nextRoomFrom = getOppositeDirection(from: nextDirection!)
            
            let nextRoomTo: [Direction]?
            
            // let's calculate the position
            var nextRoomPosition: CGPoint = CGPoint(x: 0, y: 0)
            switch nextRoomFrom {
            case .Left:
                nextRoomPosition.x = currentRoom.position.x + roomGridSize.width
                nextRoomPosition.y = currentRoom.position.y
            case .Up:
                nextRoomPosition.x = currentRoom.position.x
                nextRoomPosition.y = currentRoom.position.y - roomGridSize.height
            case .Down:
                nextRoomPosition.x = currentRoom.position.x
                nextRoomPosition.y = currentRoom.position.y + roomGridSize.height
            case .Right:
                nextRoomPosition.x = currentRoom.position.x - roomGridSize.width
                nextRoomPosition.y = currentRoom.position.y
            }
            
            
            if i < roomCount {
                nextRoomTo = randomizeNextDirections(currentPosition:nextRoomPosition, positionTaken: positionTaken, from: nextRoomFrom, branch: 1)
            } else {
                nextRoomTo = nil
            }
            
            // create next room
            let nextRoom = Room(id: idCounter, from: currentRoom.id, fromDirection: nextRoomFrom, toDirection: nextRoomTo, position: nextRoomPosition)
            positionTaken[PairInt(first: Int(nextRoomPosition.x), second: Int(nextRoomPosition.y))] = true
            idCounter += 1
            
            // chain to current room
            currentRoom.to?.append(nextRoom.id)
            
            currentRoom = nextRoom
            rooms.append(nextRoom)
        }
        
        
        //        for room in rooms {
        //            let roomImage = room.getRoomImage()
        //            print("Room ID: \(room.id)")
        //            print("Room From: \(room.from)")
        //            print("Room To: \(room.to ?? [])")
        //            print("Room From Direction: \(room.fromDirection?.rawValue ?? "N/A")")
        //            print("Room To Direction: \(room.toDirection?.map { $0.rawValue } ?? [])")
        //            print("Room Image: \(roomImage)")
        //            print("Room Position: \(room.position)")
        //            print("------------------------------------")
        //        }
        return rooms
    }
    
    func setGameOver() {
        DispatchQueue.main.async {
            self.isGameOver = true
        }
    }
    
}
