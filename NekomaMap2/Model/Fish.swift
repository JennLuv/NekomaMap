//
//  Fish.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 19/06/24.
//

import SpriteKit

class Fish: SKSpriteNode {
    let imageName: String
    let fishName: String
    let bonusLives: Int
    let bonusAttack: Float
    let bonusSpeed: Float
    let specialPower: SpecialPower
    let rarity: RarityLevel
    
    init(imageName: String, fishName: String, bonusLives: Int, bonusAttack: Float, bonusSpeed: Float, specialPower: SpecialPower, rarity: RarityLevel) {
        self.imageName = imageName
        self.fishName = fishName
        self.bonusLives = bonusLives
        self.bonusAttack = bonusAttack
        self.bonusSpeed = bonusSpeed
        self.specialPower = specialPower
        self.rarity = rarity
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func allFishes() -> [Fish] {
        // print("allFishes")
        let fishes: [Fish] = [
            Fish(imageName: "salmonCommon", fishName: "salmonCommon", bonusLives: 0, bonusAttack: 0.1, bonusSpeed: 0, specialPower: SpecialPower(name: "Salmon Leap", cooldown: 100), rarity: .common),
            Fish(imageName: "salmonUncommon", fishName: "salmonUncommon", bonusLives: 0, bonusAttack: 0.2, bonusSpeed: -2, specialPower: SpecialPower(name: "Salmon Leap", cooldown: 120), rarity: .uncommon),
            Fish(imageName: "salmonRare", fishName: "salmonRare", bonusLives: 0, bonusAttack: 0.3, bonusSpeed: 0, specialPower: SpecialPower(name: "Salmon Leap", cooldown: 150), rarity: .rare),
            Fish(imageName: "mackerelCommon", fishName: "mackerelCommon", bonusLives: 1, bonusAttack: 0, bonusSpeed: 0, specialPower: SpecialPower(name: "Fresh Sashimi", cooldown: 100), rarity: .common),
            Fish(imageName: "mackerelUncommon", fishName: "mackerelUncommon", bonusLives: 2, bonusAttack: -0.1, bonusSpeed: -1, specialPower: SpecialPower(name: "Fresh Sashimi", cooldown: 120), rarity: .uncommon),
            Fish(imageName: "mackerelRare", fishName: "mackerelRare", bonusLives: 2, bonusAttack: 0, bonusSpeed: 0, specialPower: SpecialPower(name: "Fresh Sashimi", cooldown: 150), rarity: .rare),
            Fish(imageName: "tunaCommon", fishName: "tunaCommon", bonusLives: 0, bonusAttack: 0, bonusSpeed: 2, specialPower: SpecialPower(name: "Tuna Terror", cooldown: 100), rarity: .common),
            Fish(imageName: "tunaUncommon", fishName: "tunaUncommon", bonusLives: 0, bonusAttack: -0.2, bonusSpeed: 4, specialPower: SpecialPower(name: "Tuna Terror", cooldown: 120), rarity: .uncommon),
            Fish(imageName: "tunaRare", fishName: "tunaRare", bonusLives: 0, bonusAttack: 0, bonusSpeed: 4, specialPower: SpecialPower(name: "Tuna Terror", cooldown: 150), rarity: .rare),
            Fish(imageName: "pufferCommon", fishName: "pufferCommon", bonusLives: 0, bonusAttack: 0.05, bonusSpeed: 1, specialPower: SpecialPower(name: "Invincibility", cooldown: 100), rarity: .common),
            Fish(imageName: "pufferUncommon", fishName: "pufferUncommon", bonusLives: 1, bonusAttack: 0.1, bonusSpeed: 2, specialPower: SpecialPower(name: "Invincibility", cooldown: 5), rarity: .uncommon),
            Fish(imageName: "pufferRare", fishName: "pufferRare", bonusLives: 2, bonusAttack: 0.2, bonusSpeed: 2, specialPower: SpecialPower(name: "Invincibility", cooldown: 150), rarity: .rare)
        ]
        return fishes
    }
}

struct SpecialPower {
    let name: String
    let cooldown: Float
    // What the power does is not yet defined
}

