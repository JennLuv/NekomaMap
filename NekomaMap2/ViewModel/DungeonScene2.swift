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
    
    var playerWalkTextureAtlas = SKTextureAtlas(named: "playerWalk")
    var playerIdleTextureAtlas = SKTextureAtlas(named: "playerIdle")
    var playerIsMoving = false
    var playerStartMoving = false
    var playerStopMoving = true
    
    // Attacks
    var playerIsShooting = false
    var playerIsAttacking = false
    
    // Array
    var enemyManager = [String: Enemy2]()
    var enemyCount = 0
    
    var weaponSlot: Weapon?
    var weaponSlotButton: WeaponSlotButton!
    
    // Button Cooldown
    var buttonAOnCooldown1 = false
    var buttonAOnCooldown2 = false
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        setupCamera()
        
        let rooms = generateLevel(roomCount: 9)
        drawDungeon(rooms: rooms)
        scene?.anchorPoint = .zero
        
        player = createPlayer(at: CGPoint(x: 0, y: 0))
        
        for i in 0..<playerWalkTextureAtlas.textureNames.count {
            let textureNames = "playerWalk" + String(i)
            playerWalkFrames.append(playerWalkTextureAtlas.textureNamed(textureNames))
        }
        
        for i in 0..<playerIdleTextureAtlas.textureNames.count {
            let textureNames = "playerIdle" + String(i)
            playerIdleFrames.append(playerIdleTextureAtlas.textureNamed(textureNames))
        }
        
        addChild(player)
        
        connectVirtualController()
        weaponSlotButton = WeaponSlotButton(currentWeapon: player.equippedWeapon)
        weaponSlotButton.position = CGPoint(x: 310, y: -35)
        weaponSlotButton.zPosition = 1000
        
        cameraNode.addChild(weaponSlotButton)
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
        
        if contact.bodyA.categoryBitMask == PhysicsCategory.projectile && contact.bodyB.categoryBitMask == PhysicsCategory.enemy {
            
            let enemyCandidate1 = contact.bodyA.node as? Enemy2
            let enemyCandidate2 = contact.bodyB.node as? Enemy2
            
            if enemyCandidate1?.name == nil {
                enemyCandidate2?.takeDamage(1)
                contact.bodyA.node?.removeFromParent()
            } else if enemyCandidate2?.name == nil {
                enemyCandidate1?.takeDamage(1)
                contact.bodyB.node?.removeFromParent()
            }
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.enemy && contact.bodyB.categoryBitMask == PhysicsCategory.projectile {
            
            let enemyCandidate1 = contact.bodyA.node as? Enemy2
            let enemyCandidate2 = contact.bodyB.node as? Enemy2
            
            if enemyCandidate1?.name == nil {
                enemyCandidate2?.takeDamage(1)
                contact.bodyA.node?.removeFromParent()
            } else if enemyCandidate2?.name == nil {
                enemyCandidate1?.takeDamage(1)
                contact.bodyB.node?.removeFromParent()
            }
            
        } else if contact.bodyA.categoryBitMask == PhysicsCategory.projectile && contact.bodyB.categoryBitMask == PhysicsCategory.target {
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.categoryBitMask == PhysicsCategory.projectile && contact.bodyA.categoryBitMask == PhysicsCategory.target {
            contact.bodyB.node?.removeFromParent()
        } 
    }

    
    // MARK: Update
    
    override func update(_ currentTime: TimeInterval) {
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
        
        if let buttonA = virtualController?.controller?.extendedGamepad?.buttonA, buttonA.isPressed {
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
                let weaponSpawn2 = Weapon(imageName: player.equippedWeapon.weaponName, weaponName: player.equippedWeapon.weaponName, rarity: player.equippedWeapon.rarity)
                weaponSpawn2.position = CGPoint(x: weapon.position.x, y: weapon.position.y)
                let originalSize2 = weaponSpawn2.size
                weaponSpawn2.size = CGSize(width: originalSize2.width / 2, height: originalSize2.height / 2)
                
                // Let's put a function below player picking up the weapon
                weaponSlotButton.updateTexture(with: weaponSlot)
                player.equippedWeapon = weapon
                buttonAOnCooldown2 = true
                
                // Replace the picked up weapon from map
                weapon.removeFromParent()
                addChild(weaponSpawn2)
                
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
            
            for child in self.children{
                print(child)
            }
        }
        
        checkPlayerDistanceToChests()
        
        func checkPlayerDistanceToChests() {
            let range: CGFloat = 100.0
            for child in self.children {
//                print(child)
                if let chest = child as? Chest {
                    let distance = hypot(player.position.x - chest.position.x, player.position.y - chest.position.y)
                    if distance <= range {
                        Chest.changeTextureToOpened(chestNode: chest)
                        chest.spawnContent()
                    }
                }
            }
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
        
        func isPlayerCloseToEnemy() -> Bool {
            let weaponRange: CGFloat = 50.0 // Adjust the range as necessary
            for (_, enemy) in enemyManager {
                let distance = hypot(player.position.x - enemy.position.x, player.position.y - enemy.position.y)
                if distance <= weaponRange {
                    return true
                }
            }
            return false
        }
        
//        if let buttonB = virtualController?.controller?.extendedGamepad?.buttonB, buttonB.isPressed {
//            meleeAttack()
//        }
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
        
        self.addChild(projectile)
        
        DispatchQueue.global().asyncAfter(deadline: .now() + attackSpeed) {
            self.playerIsShooting = false
        }
    }
    
    // MARK: connectVirtualController
    
    func connectVirtualController() {
        let controllerConfig = GCVirtualController.Configuration()
        controllerConfig.elements = [GCInputLeftThumbstick, GCInputButtonA]
        
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
        
        // Get chest content for each room
        let chest = Chest(id: 0, content: nil)
        let chests = chest.generateChests(level: 5) // Assuming level 5 for example
        
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
            
            addChild(roomBgNode)
            addChild(roomNode)
            addChild(roomExtraNode)
            
            // Add chest to each room except the first one
            if room.id != 1 {
                let chest = chests.first { $0.id + 1 == room.id }
                let chestNode = Chest.createChest(at: room.position, room: room.id, content: chest?.content)
                addChild(chestNode)
            }
            
            let enemy1 = createEnemy(at: CGPoint(x: room.position.x + 100, y: room.position.y))
            let enemy2 = createEnemy(at: CGPoint(x: room.position.x - 100, y: room.position.y))
            let enemy3 = createEnemy(at: CGPoint(x: room.position.x, y: room.position.y + 100))
            
//            let weaponSpawn = Weapon(imageName: "cherryBomb", weaponName: "cherryBomb", rarity: .common)
//            weaponSpawn.position = CGPoint(x: room.position.x, y: room.position.y - 100)
//            let originalSize = weaponSpawn.size
//            weaponSpawn.size = CGSize(width: originalSize.width / 2, height: originalSize.height / 2)
//            
//            let weaponSpawn2 = Weapon(imageName: "yarnBall", weaponName: "yarnBall", rarity: .common)
//            weaponSpawn2.position = CGPoint(x: room.position.x + 50, y: room.position.y + 170)
//            let originalSize2 = weaponSpawn2.size
//            weaponSpawn2.size = CGSize(width: originalSize2.width / 2, height: originalSize2.height / 2)
            
            addChild(enemy1)
            addChild(enemy2)
            addChild(enemy3)
//            addChild(weaponSpawn)
//            addChild(weaponSpawn2)
        }
    }
    
    // MARK: createEnemy
    
    func createEnemy(at position: CGPoint) -> Enemy2 {
        let enemy = Enemy2(hp: 5, imageName: "player", maxHP: 5, name: "Enemy\(enemyCount)")
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
