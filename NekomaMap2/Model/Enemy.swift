//
//  Enemy.swift
//  NekomaMap2
//
//  Created by Nur Nisrina on 17/06/24.
//

import Foundation
import SpriteKit

class Enemy: SKSpriteNode {
    var health: Int {
        didSet {
            updateHealthBar()
        }
    }
    var maxHealth: Int
    var attackSpeed: Int
    var range: CGPoint
    private let healthBarBackground: SKSpriteNode
    private let healthBarForeground: SKSpriteNode

    init(name: String, texture: SKTexture?, color: UIColor, size: CGSize, health: Int, maxHealth: Int, speed: CGFloat, attackSpeed: Int, range: CGPoint, scale: CGFloat) {
        self.health = health
        self.maxHealth = maxHealth
        self.attackSpeed = attackSpeed
        self.range = range
        
        self.healthBarBackground = SKSpriteNode(color: .gray, size: CGSize(width: 30, height: 3))
        self.healthBarForeground = SKSpriteNode(color: .red, size: CGSize(width: 30, height: 3))
        
        super.init(texture: texture, color: color, size: size)
        self.name = name
        self.setScale(scale)
        self.setupPhysicsBody()
        self.setupHealthBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        self.physicsBody?.allowsRotation = false
    }
    
    private func setupHealthBar() {
        healthBarBackground.position = CGPoint(x: 0, y: (size.height / 2) - 10 )
        healthBarForeground.position = CGPoint(x: 0, y: (size.height / 2) - 10 )
        
        addChild(healthBarBackground)
        addChild(healthBarForeground)
        
        updateHealthBar()
    }
    
    private func updateHealthBar() {
        let healthRatio = CGFloat(health) / CGFloat(maxHealth)
        healthBarForeground.size.width = healthBarBackground.size.width * healthRatio
        healthBarForeground.position = CGPoint(x: -healthBarBackground.size.width / 2 + healthBarForeground.size.width / 2, y: healthBarBackground.position.y)
    }
    
    func chasePlayer(player: SKSpriteNode) {
        let playerPosition = player.position
        let dx = playerPosition.x - position.x
        let dy = playerPosition.y - position.y
        let angle = atan2(dy, dx)
        
        let speed: CGFloat = 20.0
        let vx = cos(angle) * speed
        let vy = sin(angle) * speed
        self.physicsBody?.velocity = CGVector(dx: vx, dy: vy)
    }
    
    func animate(frames: [SKTexture], timePerFrame: TimeInterval) {
        let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame)
        let repeatAction = SKAction.repeatForever(animation)
        self.run(repeatAction)
    }
    
    func takeDamage(_ damage: Int) {
        health -= damage
        updateHPBar()

        // Remove the enemy if its health is 0 or less
        if health <= 0 {
            self.removeFromParent()
        }
    }
    
    func spawnInScene(scene: SKScene, atPosition position: CGPoint) {
        self.position = position
        scene.addChild(self)
    }
    
    private func updateHPBar() {
        let hpRatio = CGFloat(health) / CGFloat(maxHealth)
        healthBarForeground.size.width = healthBarBackground.size.width * hpRatio
        healthBarForeground.position = CGPoint(x: -healthBarBackground.size.width / 2 + healthBarForeground.size.width / 2, y: healthBarBackground.position.y)
    }
}

class MeleeEnemy: Enemy {
    var isAttacking: Bool = false

    init() {
        let texture = SKTexture(imageNamed: "Melee")
        let scale: CGFloat = 1.7
        super.init(name: "melee", texture: texture, color: .clear, size: texture.size(), health: 5, maxHealth: 5, speed: 1.0, attackSpeed: 10, range: CGPoint(x: 10, y: 10), scale: scale)
        self.walkAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func walkAnimation() {
        let meleeFrames: [SKTexture] = [
            SKTexture(imageNamed: "meleeWalk0"),
            SKTexture(imageNamed: "meleeWalk1"),
            SKTexture(imageNamed: "meleeWalk2"),
            SKTexture(imageNamed: "meleeWalk3"),
        ]
        self.animate(frames: meleeFrames, timePerFrame: 0.1)
        
    }
    override func chasePlayer(player: SKSpriteNode) {
        if !isAttacking {
            super.chasePlayer(player: player)            } else {
                self.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            }
    }
    func meleeAttack(player: SKSpriteNode, distance: Float) {
        let attackFrames: [SKTexture] = [
            SKTexture(imageNamed: "meleeAttack0"),
            SKTexture(imageNamed: "meleeAttack1"),
            SKTexture(imageNamed: "meleeAttack2"),
            SKTexture(imageNamed: "meleeAttack3"),
            SKTexture(imageNamed: "meleeAttack4"),
            SKTexture(imageNamed: "meleeAttack5")
        ]
        if !isAttacking && distance < 60 {
            self.animate(frames: attackFrames, timePerFrame: 0.1)
            isAttacking = true
        }
    }

}


class RangedEnemy: Enemy {
    private var isShooting = false
    
    init() {
        let texture = SKTexture(imageNamed: "Ranged")
        let scale: CGFloat = 2.0
        super.init(name: "ranged", texture: texture, color: .clear, size: texture.size(), health: 5, maxHealth: 5, speed: 0.4, attackSpeed: 20, range: CGPoint(x: 20, y: 20), scale: scale)
        self.walkAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func walkAnimation() {
        let rangedFrames: [SKTexture] = [
            SKTexture(imageNamed: "rangedWalk0"),
            SKTexture(imageNamed: "rangedWalk1"),
            SKTexture(imageNamed: "rangedWalk2"),
            SKTexture(imageNamed: "rangedWalk3"),
            SKTexture(imageNamed: "rangedWalk4")
        ]
        self.animate(frames: rangedFrames, timePerFrame: 0.1)
    }
    
    func shootBullet(player: SKSpriteNode, scene: SKScene) {
        guard !isShooting else {
            return // Prevent rapid shooting
        }

        isShooting = true

        let bulletTexture = SKTexture(imageNamed: "rangedBullet2")
        let bullet = SKSpriteNode(texture: bulletTexture)
        bullet.position = self.position
        bullet.setScale(0.5)

        // Physics for bullet
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = 0x1 << 2
        bullet.physicsBody?.contactTestBitMask = 0x1 << 0 | 0x1 << 1 // Player and other objects
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true

       
        let collisionAction = SKAction.run {
            bullet.removeFromParent()
            self.isShooting = false
        }

        let delayAction = SKAction.wait(forDuration: 1.0)
        let actions = [delayAction, collisionAction]
        bullet.run(SKAction.sequence(actions))

        scene.addChild(bullet)

        let dx = player.position.x - bullet.position.x
        let dy = player.position.y - bullet.position.y
        let angle = atan2(dy, dx)

        let speed: CGFloat = 100.0
        let vx = cos(angle) * speed
        let vy = sin(angle) * speed
        bullet.physicsBody?.velocity = CGVector(dx: vx, dy: vy)
    }

}
