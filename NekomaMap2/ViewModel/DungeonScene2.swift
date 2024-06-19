//
//  DungeonRoomViewModel.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 10/06/24.
//

import Foundation
import SpriteKit
import GameController

class DungeonScene2: SKScene, SKPhysicsContactDelegate {
    var idCounter = 1
    var cameraNode: SKCameraNode!
    
    //Joystick
    var player: Player2!
    var virtualController: GCVirtualController?
    var playerPosx: CGFloat = 0
    var playerPosy: CGFloat = 0
    
    // Movement
    var playerMovedLeft = false
    var playerMovedRight = false
    var playerLooksLeft = false
    var playerLooksRight = true
    
    var playerWalkFrames = [SKTexture]()
    var playerIdleFrames = [SKTexture]()
    var playerSalmonFrames = [SKTexture]()
    var playerTunaFrames = [SKTexture]()
    var playerMackarelFrames = [SKTexture]()
    var playerPufferFrames = [SKTexture]()
    
    var playerWalkTextureAtlas = SKTextureAtlas(named: "playerWalk")
    var playerIdleTextureAtlas = SKTextureAtlas(named: "playerIdle")
    var playerSalmonTextureAtlas = SKTextureAtlas(named: "playerSalmon")
    var playerTunaTextureAtlas = SKTextureAtlas(named: "playerTuna")
    var playerMackarelTextureAtlas = SKTextureAtlas(named: "playerMackarel")
    var playerPufferTextureAtlas = SKTextureAtlas(named: "playerPuffer")
    var playerIsMoving = false
    var playerStartMoving = false
    var playerStopMoving = true
    
    // Attacks
    var playerIsShooting = false
    var playerIsAttacking = false
    
    // Array
    var enemyManager = [String: Enemy2]()
    
    var weaponSlot: Weapon?
    var weaponSlotButton: WeaponSlotButton!
    var fishSlot: Fish?
    var fishSlotButton: FishSlotButton!
    
    // Button Cooldown
    var buttonAOnCooldown1 = false
    var buttonAOnCooldown2 = false
    
    var rooms: [Room]?
    var enemyIsAttacked = false
    
    var enemyCount: Int = 0
    var currentEnemyCount: Int = 0
    
    let buttonZPos = 5
    let shootOrMeleeZPos = 4
    let playerZPos = 3
    let enemyZPos = 2
    let weaponSpawnZPos = 1
    let roomZPos = 0
    var customButton: SKSpriteNode!
    var customButtomPosX = 300
    var customButtomPosY = -100
    
    var buttonAIsPressed: Bool = false
    
    var changeButtonToAlert: Bool = false
    var buttonImageName: String = "buttonAttack"
    
    
    override func didMove(to view: SKView) {
        
        enemyCount = countEnemies()
        let customButton = updateButtonImage()
                
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        if let controller = GCController.controllers().first {
                if let gamepad = controller.extendedGamepad {
                    gamepad.buttonA.pressedChangedHandler = { (button, value, pressed) in
                        if pressed {
                            self.customButtonPressed()
                        } else {
                            self.customButtonReleased()
                        }
                    }
                }
            }
        
        setupCamera()
        
        rooms = generateLevel(roomCount: 9)
        drawDungeon(rooms: rooms!)
        scene?.anchorPoint = .zero
        
        player = createPlayer(at: CGPoint(x: 0, y: 0))
        
        func atlasInit(textureAtlas: SKTextureAtlas, textureAltasName: String) -> [SKTexture] {
            var textures = [SKTexture]()
            for i in 0..<textureAtlas.textureNames.count {
                var textureNames = textureAltasName + String(i)
                textures.append(textureAtlas.textureNamed(textureNames))
            }
            return textures
        }
        playerWalkFrames = atlasInit(textureAtlas: playerWalkTextureAtlas, textureAltasName: "playerWalk")
        playerIdleFrames = atlasInit(textureAtlas: playerIdleTextureAtlas, textureAltasName: "playerIdle")
        playerSalmonFrames = atlasInit(textureAtlas: playerSalmonTextureAtlas, textureAltasName: "playerSalmon")
        playerTunaFrames = atlasInit(textureAtlas: playerTunaTextureAtlas, textureAltasName: "playerTuna")
        playerMackarelFrames = atlasInit(textureAtlas: playerMackarelTextureAtlas, textureAltasName: "playerMackarel")
        playerPufferFrames = atlasInit(textureAtlas: playerPufferTextureAtlas, textureAltasName: "playerPuffer")
        
        player.zPosition = CGFloat(playerZPos)
        addChild(player)
        
        connectVirtualController()
        weaponSlotButton = WeaponSlotButton(currentWeapon: player.equippedWeapon)
        weaponSlotButton.position = CGPoint(x: customButtomPosX + 27, y: customButtomPosY + 100)
        weaponSlotButton.zPosition = 1000
        
        weaponSlotButton.zPosition = CGFloat(buttonZPos)
        cameraNode.addChild(weaponSlotButton)
        
        fishSlotButton = FishSlotButton(currentFish: player.equippedFish)
        fishSlotButton.position = CGPoint(x: customButtomPosX - 100, y: customButtomPosY - 27)
        fishSlotButton.zPosition = 1000
        
        fishSlotButton.zPosition = CGFloat(buttonZPos)
        cameraNode.addChild(fishSlotButton)
        
        cameraNode.addChild(customButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            if touchedNode.name == "customButton" {
                customButtonPressed()
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            if touchedNode.name == "customButton" {
                customButtonReleased()
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
    
    // Example function to change the state and update the button
    func changeButtonState(toAlert: Bool) -> SKSpriteNode {
        changeButtonToAlert = toAlert
        let newImage = updateButtonImage()
        return newImage
    }
    
    func customButtonPressed() {
        buttonAIsPressed = true
        print("Custom button pressed")
    }

    func customButtonReleased() {
        buttonAIsPressed = false
        print("Custom button released")
    }


    
    // MARK: createPlayer
    
    func createPlayer(at position: CGPoint) -> Player2 {
        let player = Player2(hp: 20, imageName: "player", maxHP: 20, name: "Player1")
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
        
        if contact.bodyB.categoryBitMask == PhysicsCategory.enemy && contact.bodyA.categoryBitMask == PhysicsCategory.projectile {
            
            let enemyCandidate1 = contact.bodyA.node as? Enemy2
            let enemyCandidate2 = contact.bodyB.node as? Enemy2
            
            if enemyCandidate1?.name == nil && enemyCandidate2?.name != nil {
                enemyCandidate2?.takeDamage(1)
                contact.bodyA.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                if enemyCount-3 == currentEnemyCount {
                    handleJailRemoval()
                    enemyCount = enemyCount-3
                    return
                }
                
                let enemyName = contact.bodyB.node?.name
                if !enemyIsAttacked {
                    if !enemyIsAttacked {
                        handleEnemyComparison(enemyName: enemyName!)
                    }
                }
                
            } else if enemyCandidate2?.name == nil && enemyCandidate1?.name != nil {
                enemyCandidate1?.takeDamage(1)
                contact.bodyB.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                if enemyCount-3 == currentEnemyCount {
                    handleJailRemoval()
                    enemyCount = enemyCount-3
                    return
                }
                
                let enemyName = contact.bodyA.node?.name
                if !enemyIsAttacked {
                    handleEnemyComparison(enemyName: enemyName!)
                }
            }
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.enemy && contact.bodyB.categoryBitMask == PhysicsCategory.projectile {
            
            let enemyCandidate1 = contact.bodyA.node as? Enemy2
            let enemyCandidate2 = contact.bodyB.node as? Enemy2
            
            if enemyCandidate1?.name == nil && enemyCandidate2?.name != nil {
                enemyCandidate2?.takeDamage(1)
                contact.bodyA.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                if enemyCount == currentEnemyCount {
                    handleJailRemoval()
                    enemyCount = enemyCount-3
                    return
                }
                
                let enemyName = contact.bodyB.node?.name
                if !enemyIsAttacked {
                    if !enemyIsAttacked {
                        handleEnemyComparison(enemyName: enemyName!)
                    }
                }
                
            } else if enemyCandidate2?.name == nil && enemyCandidate1?.name != nil{
                enemyCandidate1?.takeDamage(1)
                contact.bodyB.node?.removeFromParent()
                currentEnemyCount = countEnemies()
                
                if enemyCount-3 == currentEnemyCount {
                    handleJailRemoval()
                    enemyCount = enemyCount-3
                    return
                }
                
                let enemyName = contact.bodyA.node?.name
                if !enemyIsAttacked {
                    if !enemyIsAttacked {
                        handleEnemyComparison(enemyName: enemyName!)
                    }
                }
                
            }
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.projectile && contact.bodyB.categoryBitMask == PhysicsCategory.target {
            contact.bodyA.node?.removeFromParent()
            
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.projectile && contact.bodyA.categoryBitMask == PhysicsCategory.target {
            contact.bodyB.node?.removeFromParent()
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.wall && contact.bodyB.categoryBitMask == PhysicsCategory.projectile {
            contact.bodyB.node?.removeFromParent()
            
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.wall && contact.bodyA.categoryBitMask == PhysicsCategory.projectile {
            contact.bodyA.node?.removeFromParent()
            
        }
    }
    
    func handleJailRemoval() {
        removeNodesWithJail()
        enemyIsAttacked = false
    }
    
    func randomPosition(in room: Room) -> CGPoint {
        let minX = room.position.x - (360 / 2)
        let maxX = room.position.x + (360 / 2)
        let minY = room.position.y - (360 / 2)
        let maxY = room.position.y + (360 / 2)
        
        let randomX = CGFloat.random(in: minX..<maxX)
        let randomY = CGFloat.random(in: minY..<maxY)
        
        return CGPoint(x: randomX, y: randomY)
    }
    
    func handleEnemyComparison(enemyName: String) {
        switch enemyName {
        case "Enemy0", "Enemy1", "Enemy2":
            handleEnemyAttack(roomNum: 0)
        case "Enemy3", "Enemy4", "Enemy5":
            handleEnemyAttack(roomNum: 1)
        case "Enemy6", "Enemy7", "Enemy8":
            handleEnemyAttack(roomNum: 2)
        case "Enemy9", "Enemy10", "Enemy11":
            handleEnemyAttack(roomNum: 3)
        case "Enemy12", "Enemy13", "Enemy14":
            handleEnemyAttack(roomNum: 4)
        case "Enemy15", "Enemy16", "Enemy17":
            handleEnemyAttack(roomNum: 5)
        case "Enemy18", "Enemy19", "Enemy20":
            handleEnemyAttack(roomNum: 6)
        case "Enemy21", "Enemy22", "Enemy23":
            handleEnemyAttack(roomNum: 7)
        case "Enemy24", "Enemy25", "Enemy26":
            handleEnemyAttack(roomNum: 8)
        case "Enemy27", "Enemy28", "Enemy29":
            handleEnemyAttack(roomNum: 9)
        default:
            print("Unknown enemy")
        }
    }
    
    func removeNodesWithJail() {
        let jailNodes = children.filter { node in
            return node.physicsBody?.categoryBitMask == PhysicsCategory.wall
        }
        jailNodes.forEach { $0.removeFromParent() }
    }
    
    
    func countEnemies() -> Int {
        let enemyNodes = children.filter { node in
            return node.name?.contains("Enemy") ?? false
        }
        return enemyNodes.count
    }
    
    func handleEnemyAttack(roomNum: Int) {
        let currentRoom = rooms![roomNum]
        let jailNode = SKSpriteNode(imageNamed: currentRoom.getRoomImage().jailName)
        jailNode.position = currentRoom.position
        
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
        
        
        jailNode.zPosition = CGFloat(roomZPos)
        jailExtraNode.zPosition = CGFloat(roomZPos)
        addChild(jailNode)
        addChild(jailExtraNode)
        enemyIsAttacked = true
    }
    
    
    // MARK: Update
    
    override func update(_ currentTime: TimeInterval) {
        
        if saveFishToSlotWhenNear() != nil || saveWeaponToSlotWhenNear() != nil{
            customButton = changeButtonState(toAlert: true)
            cameraNode.addChild(customButton)
        } else {
            customButton = changeButtonState(toAlert: false)
            cameraNode.addChild(customButton)
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
                playerStartMoving = false
                player.removeAllActions()
                player.run(SKAction.repeatForever(SKAction.animate(with: playerWalkFrames, timePerFrame: 0.1)))
            }
            if playerStopMoving {
                playerStopMoving = false
                player.removeAllActions()
                player.run(SKAction.repeatForever(SKAction.animate(with: playerIdleFrames, timePerFrame: 0.2)))
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
        }
        //here
        
        if buttonAIsPressed {
            // Add a global buttonA cooldown, preventing any spam function calls
            if buttonAOnCooldown1 || buttonAOnCooldown2 {
                return
            }
            buttonAOnCooldown1 = true
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
                self.buttonAOnCooldown1 = false
            }
            
            // If nearby weapon, then A button should swap weapon
            if let weapon = saveWeaponToSlotWhenNear(), saveWeaponToSlotWhenNear() != nil {
                // TODO: refactor placing weapon on map
                let weaponSpawn2 = Weapon(imageName: player.equippedWeapon.weaponName, weaponName: player.equippedWeapon.weaponName)
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
                return
            }
            
            if let fish = saveFishToSlotWhenNear(), saveFishToSlotWhenNear() != nil {
                // TODO: refactor placing weapon on map
                
                fishSlotButton.updateTexture(with: fishSlot)
                let fishName = fishSlot!.fishName
                switch fishName {
                case "tunaCommon", "tunaUncommon", "tunaRare":
                    player.run(SKAction.animate(with: playerTunaFrames, timePerFrame: 0.1))
                case "salmonCommon", "salmonUncommon", "salmonRare":
                    player.run(SKAction.animate(with: playerSalmonFrames, timePerFrame: 0.1))
                case "mackarelCommon", "mackarelUncommon", "mackarelRare":
                    player.run(SKAction.animate(with: playerMackarelFrames, timePerFrame: 0.1))
                case "pufferCommon", "pufferUncommon", "pufferRare":
                    player.run(SKAction.animate(with: playerPufferFrames, timePerFrame: 0.1))
                default:
                    break
                }
                

                
                //here2
                
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
            
            if isPlayerCloseToEnemy() {
                meleeAttack()
            } else {
                shootImage()
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
            
            for child in self.children {
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
            
            for child in self.children {
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
        
        for enemyPair in enemyManager {
            let enemyName = enemyPair.key
            let enemy = enemyPair.value
            let distance = hypotf(Float(enemy.position.x - player.position.x), Float(enemy.position.y - player.position.y))
            if distance < 150 {
                enemy.chasePlayer(player: player)
                
                if let rangedEnemy = enemy as? RangedEnemy {
                    rangedEnemy.shootBullet(player: player, scene: self)
                }
            }
        }
        
    }
    
    
    // MARK: meleeAttack
    
    func meleeAttack() {
        let attackSpeed = 0.4
        let weaponRange = 2
        if playerIsAttacking {
            return
        }
        playerIsAttacking = true
        
        var direction = 1
        if playerLooksLeft {
            direction = -1
        }
        
        let hitbox = SKSpriteNode(imageNamed: player.equippedWeapon.weaponName)
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
        self.addChild(hitbox)
        self.addChild(hitboxImage)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
            hitbox.removeFromParent()
            hitboxImage.removeFromParent()
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + attackSpeed) {
            self.playerIsAttacking = false
        }
    }
    
    // MARK: ShootImage
    
    func shootImage() {
        let attackSpeed = 1.0
        let projectileSpeed = 100
        if playerIsShooting {
            return
        }
        playerIsShooting = true
        
        var direction = 1
        if playerLooksLeft {
            direction = -1
        }
        
        let projectile = SKSpriteNode(imageNamed: player.equippedWeapon.weaponName)
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
        cameraNode.setScale(0.8)
        addChild(cameraNode)
    }
    
    // MARK: drawDungeon
    
    func drawDungeon(rooms: [Room]) {
        
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
            
            
            let fishSpawn = Fish(imageName: "tunaCommon", fishName: "tunaCommon")
            fishSpawn.position = CGPoint(x: room.position.x, y: room.position.y - 70)
            let originalSize4 = fishSpawn.size
            fishSpawn.size = CGSize(width: originalSize4.width / 2, height: originalSize4.height / 2)
            
            let fishSpawn2 = Fish(imageName: "pufferCommon", fishName: "pufferCommon")
            fishSpawn2.position = CGPoint(x: room.position.x + 5, y: room.position.y - 10)
            let originalSize3 = fishSpawn2.size
            fishSpawn2.size = CGSize(width: originalSize3.width / 2, height: originalSize3.height / 2)
            
            let weaponSpawn = Weapon(imageName: "cherryBomb", weaponName: "cherryBomb")
            weaponSpawn.position = CGPoint(x: room.position.x, y: room.position.y - 100)
            let originalSize = weaponSpawn.size
            weaponSpawn.size = CGSize(width: originalSize.width / 2, height: originalSize.height / 2)
            
            let weaponSpawn2 = Weapon(imageName: "yarnBall", weaponName: "yarnBall")
            weaponSpawn2.position = CGPoint(x: room.position.x + 50, y: room.position.y + 170)
            let originalSize2 = weaponSpawn2.size
            weaponSpawn2.size = CGSize(width: originalSize2.width / 2, height: originalSize2.height / 2)
            
            weaponSpawn.zPosition = CGFloat(weaponSpawnZPos)
            weaponSpawn2.zPosition = CGFloat(weaponSpawnZPos)
            
            for _ in 0..<Int.random(in: 1...1) {
                let enemy = createEnemy(at: randomPosition(in: room), variant: "Ranged")
                addChild(enemy)
            }
            for _ in 0..<Int.random(in: 2...2) {
                let enemy = createEnemy(at: randomPosition(in: room), variant: "Melee")
                addChild(enemy)
            }
            addChild(weaponSpawn)
            addChild(weaponSpawn2)
            addChild(fishSpawn)
            addChild(fishSpawn2)
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
        
        print("Generate level invoked")
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
        
        
        for room in rooms {
            let roomImage = room.getRoomImage()
            print("Room ID: \(room.id)")
            print("Room From: \(room.from)")
            print("Room To: \(room.to ?? [])")
            print("Room From Direction: \(room.fromDirection?.rawValue ?? "N/A")")
            print("Room To Direction: \(room.toDirection?.map { $0.rawValue } ?? [])")
            print("Room Image: \(roomImage)")
            print("Room Position: \(room.position)")
            print("------------------------------------")
        }
        return rooms
    }
    
}
