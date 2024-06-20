//
//  Weapon.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 18/06/24.
//

import SpriteKit

class Weapon: SKSpriteNode {
    var imageName: String
    var weaponName: String
    var rarity: RarityLevel

    init(imageName: String, weaponName: String, rarity: RarityLevel) {
        self.imageName = imageName
        self.weaponName = weaponName
        self.rarity = rarity
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
        self.name = "weapon"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func allWeapons() -> [Weapon] {
        let weapons: [Weapon] = [
            Weapon(imageName: "cherryBomb", weaponName: "cherryBomb", rarity: .common),
            Weapon(imageName: "fishboneSword", weaponName: "fishboneSword", rarity: .common),
            Weapon(imageName: "laserPointer", weaponName: "laserPointer", rarity: .common),
            Weapon(imageName: "rainbowCatnip", weaponName: "rainbowCatnip", rarity: .uncommon),
            Weapon(imageName: "shuriken", weaponName: "shuriken", rarity: .uncommon),
            Weapon(imageName: "tigerClaw", weaponName: "tigerClaw", rarity: .rare),
            Weapon(imageName: "yarnBall", weaponName: "yarnBall", rarity: .rare),
        ]
        return weapons
    }
}
