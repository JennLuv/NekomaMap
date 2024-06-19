//
//  Fish.swift
//  NekomaMap2
//
//  Created by Brendan Alexander Soendjojo on 19/06/24.
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
}

struct SpecialPower {
    let name: String
    let cooldown: Float
    // What the power does is not yet defined
}
