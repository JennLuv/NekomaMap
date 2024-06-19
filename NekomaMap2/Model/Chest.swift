//
//  Chest.swift
//  NekomaMap2
//
//  Created by Brendan Alexander Soendjojo on 19/06/24.
//

import SpriteKit

enum RarityLevel: String {
    case common, uncommon, rare
}

enum ChestType: String {
    case basic, special
}

enum ChestContent {
    case single(ChestContentType), multiple([ChestContentType])
}

enum ChestContentType {
    case weapon(Weapon), fish(Fish)
}

class Chest: SKSpriteNode {
    let id: Int
    let content: ChestContent?
    let currentLevel: Int = 5
    // Chest
    static let chestTextureAtlas = SKTextureAtlas(named: "chest")
    
    static let levelConfig: [Int: (roomsWithChest: Int, filledChests: Int, bossAppear: Bool)] = [
        1: (roomsWithChest: 4, filledChests: 2, bossAppear: false),
        2: (roomsWithChest: 5, filledChests: 2, bossAppear: false),
        3: (roomsWithChest: 6, filledChests: 3, bossAppear: false),
        4: (roomsWithChest: 7, filledChests: 3, bossAppear: false),
        5: (roomsWithChest: 7, filledChests: 4, bossAppear: true)
    ]

    let weapons: [Weapon] = [
        Weapon(imageName: "cherryBomb", weaponName: "cherryBomb", rarity: .common),
        Weapon(imageName: "fishboneSword", weaponName: "fishboneSword", rarity: .common),
        Weapon(imageName: "laserPointer", weaponName: "laserPointer", rarity: .common),
        Weapon(imageName: "rainbowCatnip", weaponName: "rainbowCatnip", rarity: .uncommon),
        Weapon(imageName: "shuriken", weaponName: "shuriken", rarity: .uncommon),
        Weapon(imageName: "tigerClaw", weaponName: "tigerClaw", rarity: .rare),
        Weapon(imageName: "yarnBall", weaponName: "yarnBall", rarity: .rare),
    ]
    let fishes: [Fish] = [
        Fish(imageName: "yarnBall", fishName: "Salmon", bonusLives: 0, bonusAttack: 0.1, bonusSpeed: 0, specialPower: SpecialPower(name: "Salmon Leap", cooldown: 100), rarity: .common),
        Fish(imageName: "yarnBall", fishName: "Salmon", bonusLives: 0, bonusAttack: 0.2, bonusSpeed: -2, specialPower: SpecialPower(name: "Salmon Leap", cooldown: 120), rarity: .uncommon),
        Fish(imageName: "yarnBall", fishName: "Salmon", bonusLives: 0, bonusAttack: 0.3, bonusSpeed: 0, specialPower: SpecialPower(name: "Salmon Leap", cooldown: 150), rarity: .rare),
        Fish(imageName: "yarnBall", fishName: "Sashimi", bonusLives: 1, bonusAttack: 0, bonusSpeed: 0, specialPower: SpecialPower(name: "Fresh Sashimi", cooldown: 100), rarity: .common),
        Fish(imageName: "yarnBall", fishName: "Sashimi", bonusLives: 2, bonusAttack: -0.1, bonusSpeed: -1, specialPower: SpecialPower(name: "Fresh Sashimi", cooldown: 120), rarity: .uncommon),
        Fish(imageName: "yarnBall", fishName: "Sashimi", bonusLives: 2, bonusAttack: 0, bonusSpeed: 0, specialPower: SpecialPower(name: "Fresh Sashimi", cooldown: 150), rarity: .rare),
        Fish(imageName: "yarnBall", fishName: "Tuna", bonusLives: 0, bonusAttack: 0, bonusSpeed: 2, specialPower: SpecialPower(name: "Tuna Terror", cooldown: 100), rarity: .common),
        Fish(imageName: "yarnBall", fishName: "Tuna", bonusLives: 0, bonusAttack: -0.2, bonusSpeed: 4, specialPower: SpecialPower(name: "Tuna Terror", cooldown: 120), rarity: .uncommon),
        Fish(imageName: "yarnBall", fishName: "Tuna", bonusLives: 0, bonusAttack: 0, bonusSpeed: 4, specialPower: SpecialPower(name: "Tuna Terror", cooldown: 150), rarity: .rare),
        Fish(imageName: "yarnBall", fishName: "Puffer Fish", bonusLives: 0, bonusAttack: 0.05, bonusSpeed: 1, specialPower: SpecialPower(name: "Invincibility", cooldown: 100), rarity: .common),
        Fish(imageName: "yarnBall", fishName: "Puffer Fish", bonusLives: 1, bonusAttack: 0.1, bonusSpeed: 2, specialPower: SpecialPower(name: "Invincibility", cooldown: 5), rarity: .uncommon),
        Fish(imageName: "yarnBall", fishName: "Puffer Fish", bonusLives: 2, bonusAttack: 0.2, bonusSpeed: 2, specialPower: SpecialPower(name: "Invincibility", cooldown: 150), rarity: .rare)
    ]
    
    // MARK: Initialization
    init(id: Int, content: ChestContent?) {
        self.id = id
        self.content = content
        let texture = SKTexture(imageNamed: "chestNormalClosed1")
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Creating a Chest
    static func createChest(at position: CGPoint, room: Int, content: ChestContent?) -> Chest {
        let chest = Chest(id: room, content: content)
        chest.position = position
        chest.size = CGSize(width: 40, height: 40)
        chest.physicsBody = SKPhysicsBody(rectangleOf: chest.size)
        chest.physicsBody?.isDynamic = false
        chest.physicsBody?.usesPreciseCollisionDetection = true
        chest.physicsBody?.categoryBitMask = PhysicsCategory.target
        chest.physicsBody?.collisionBitMask = PhysicsCategory.none
        chest.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        
        // Assign chest content (for illustration purposes)
//        chestNode.userData = ["content": content]
        
        // Run chest animation
        chest.run(createChestAnimation())
        
        return chest
    }
    
    // MARK: Animating Chest (Shiny, Shimmering, Splendid)
    static func createChestAnimation() -> SKAction {
        var chestFrames: [SKTexture] = []
        for i in 1...5 {
            let textureName = "chestNormalClosed\(i)"
            chestFrames.append(chestTextureAtlas.textureNamed(textureName))
        }
        return SKAction.repeatForever(SKAction.animate(with: chestFrames, timePerFrame: 0.2))
    }
    
    static func changeTextureToOpened(chestNode: SKSpriteNode) {
       chestNode.texture = SKTexture(imageNamed: "chestNormalOpened")
       chestNode.removeAllActions()
    }

    // MARK: Generating Chest For All Rooms in a Level
    func generateChests(level: Int) -> [Chest] {
        guard let config = Chest.levelConfig[level] else {
            print("Level unavailable")
            return []
        }
        
        return distributeChests(roomsWithChest: config.roomsWithChest, filledChests: config.filledChests, bossAppear: config.bossAppear)
    }

    func distributeChests(roomsWithChest: Int, filledChests: Int, bossAppear: Bool) -> [Chest] {
        var chestPlacement: [Chest] = []
        var chestLeft: Int = filledChests
        var chestContent: ChestContent?
        
        for roomNumber in 1...roomsWithChest {
            chestContent = nil
            if roomNumber == roomsWithChest {
                if bossAppear {
                    chestContent = .multiple([getWeapon(rarityValue: .rare)!, getFish(rarityValue: .rare)!])
                } else {
                    chestContent = .single(getChestContent(lastRoom: true)!)
                }
                chestLeft -= 1
            } else if chestLeft > 1 {
                if roomNumber % 2 == 0 {
                    chestContent = .single(getChestContent(lastRoom: false)!)
                    chestLeft -= 1
                }
            }
            chestPlacement.append(Chest(id: roomNumber, content: chestContent))
        }
        
        // For printing result, gonna delete later
        for item in chestPlacement {
            if let content = item.content {
                switch content {
                case .single(let type):
                    switch type {
                    case .fish(let fish):
                        print("Chest \(item.id): ContentType: Fish, Name: \(fish.fishName)")
                    case .weapon(let weapon):
                        print("Chest \(item.id): ContentType: Weapon, Name: \(weapon.weaponName)")
                    }
                case .multiple(let types):
                    for type in types {
                        switch type {
                        case .fish(let fish):
                            print("Chest \(item.id): ContentType: Fish, Name: \(fish.fishName)")
                        case .weapon(let weapon):
                            print("Chest \(item.id): ContentType: Weapon, Name: \(weapon.weaponName)")
                        }
                    }
                }
            } else {
                print("Chest \(item.id): Empty")
            }
        }
        
        return chestPlacement
    }
    
    func getChestContent(lastRoom: Bool) -> ChestContentType? {
        let randomValue = Float.random(in: 0...1)
        let rarityValue = getRarity()
        let chance: Float = {
            return lastRoom ? 0.1 : 0.8
        }()
        
        if randomValue <= chance {
            return getWeapon(rarityValue: rarityValue)
        } else {
            return getFish(rarityValue: rarityValue)
        }
    }
    
    func getRarity() -> RarityLevel? {
        let randomValue = Float.random(in: 0...1)
        let modifier = Float(currentLevel)
        if randomValue <= (0.1 * modifier - max(0 , 0.05 * (modifier - 1))) {
            return .rare
        } else if randomValue > (0.1 * modifier - max(0 , 0.05 * (modifier - 1))) && randomValue <= (0.3 + 0.1 * (modifier)) {
            return .uncommon
        } else {
            return .common
        }
    }
    
    func getWeapon(rarityValue: RarityLevel?) -> ChestContentType? {
        let filteredWeapons = weapons.filter { $0.rarity == rarityValue }
        if let randomWeapon = filteredWeapons.randomElement() {
            return .weapon(randomWeapon)
        }
        return nil
    }
    
    func getFish(rarityValue: RarityLevel?) -> ChestContentType? {
        let filteredFish = fishes.filter { $0.rarity == rarityValue }
        if let randomFish = filteredFish.randomElement() {
            return .fish(randomFish)
        }
        return nil
    }
    
    // MARK: Spawning Weapon When Chest is Opened
    func spawnContent() {
        guard let content = self.content else { return }
        switch content {
        case .single(let contentType):
            spawn(contentType)
        case .multiple(let contentTypes):
            spawnMultiple(contentTypes)
        }
    }

    private func spawn(_ contentType: ChestContentType) {
        switch contentType {
        case .weapon(let weapon):
            spawnWeapon(weapon, xCoordinate: 0, yCoordinate: -20)
        case .fish(let fish):
            spawnFish(fish, xCoordinate: 0, yCoordinate: -20)
        }
    }
    
    private func spawnMultiple(_ contentTypes: [ChestContentType]){
        for contentType in contentTypes{
            switch contentType {
            case .weapon(let weapon):
                spawnWeapon(weapon, xCoordinate: -20, yCoordinate: -20)
            case .fish(let fish):
                spawnFish(fish, xCoordinate: 20, yCoordinate: -20)
            }
        }
    }

    private func spawnWeapon(_ weapon: Weapon, xCoordinate: CGFloat, yCoordinate: CGFloat) {
        let weaponNode = Weapon(imageName: weapon.imageName, weaponName: weapon.weaponName, rarity: weapon.rarity)
        weaponNode.position = CGPoint(x: self.position.x + xCoordinate, y: self.position.y + yCoordinate)
        let originalSize = weaponNode.size
        weaponNode.size = CGSize(width: originalSize.width / 2, height: originalSize.height / 2)
        self.parent?.addChild(weaponNode)
    }
    
    private func spawnFish(_ fish: Fish, xCoordinate: CGFloat, yCoordinate: CGFloat) {
        let fishNode = Fish(imageName: fish.imageName, fishName: fish.fishName, bonusLives: fish.bonusLives, bonusAttack: fish.bonusAttack, bonusSpeed: fish.bonusSpeed, specialPower: fish.specialPower, rarity: fish.rarity)
        fishNode.position = CGPoint(x: self.position.x + xCoordinate, y: self.position.y + yCoordinate)
        let originalSize = fishNode.size
        fishNode.size = CGSize(width: originalSize.width / 2, height: originalSize.height / 2)
        self.parent?.addChild(fishNode)
    }
}


