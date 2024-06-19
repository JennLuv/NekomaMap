//
//  Player2.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 17/06/24.
//

import SpriteKit

let defaultWeapon = Weapon(imageName: "laserPointer", weaponName: "laserPointer", rarity: .common)

class Player2: SKSpriteNode {
    var hp: Int {
        didSet {
            updateHPBar()
        }
    }
    var maxHP: Int
    var equippedWeapon: Weapon
    private let hpBarBackground: SKSpriteNode
    private let hpBarForeground: SKSpriteNode

    init(hp: Int, imageName: String, maxHP: Int, name: String) {
        self.hp = hp
        self.maxHP = maxHP
        let texture = SKTexture(imageNamed: imageName)
        
        self.hpBarBackground = SKSpriteNode(color: .gray, size: CGSize(width: 50, height: 5))
        self.hpBarForeground = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 5))
        
        self.equippedWeapon = defaultWeapon
        
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.name = name
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.isDynamic = true
        
        self.position = CGPoint(x: 0, y: 0)
        self.setScale(0.55)
        
        // Configure the HP bar
        hpBarBackground.position = CGPoint(x: 0, y: size.height / 2 + 15)
        hpBarForeground.position = CGPoint(x: 0, y: size.height / 2 + 15)
        
        addChild(hpBarBackground)
        addChild(hpBarForeground)
        
        updateHPBar()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func spawnInScene(scene: SKScene, atPosition position: CGPoint) {
        self.position = position
        scene.addChild(self)
    }

    func takeDamage(_ damage: Int) {
        hp -= damage
        updateHPBar()
        
        if hp <= 0 {
            self.removeFromParent()
        }
    }

    private func updateHPBar() {
        let hpRatio = CGFloat(hp) / CGFloat(maxHP)
        hpBarForeground.size.width = hpBarBackground.size.width * hpRatio
        hpBarForeground.position = CGPoint(x: -hpBarBackground.size.width / 2 + hpBarForeground.size.width / 2, y: hpBarBackground.position.y)
    }
}
