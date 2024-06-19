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
}
