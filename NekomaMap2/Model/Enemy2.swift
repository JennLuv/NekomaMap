import SpriteKit

class Enemy2: SKSpriteNode {
    var hp: Int {
        didSet {
            updateHPBar()
        }
    }
    var maxHP: Int
    private let hpBarBackground: SKSpriteNode
    private let hpBarForeground: SKSpriteNode

    init(hp: Int, imageName: String, maxHP: Int, name: String) {
        self.hp = hp
        self.maxHP = maxHP
        let texture = SKTexture(imageNamed: imageName)
        
        self.hpBarBackground = SKSpriteNode(color: .gray, size: CGSize(width: 50, height: 5))
        self.hpBarForeground = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 5))
        
        super.init(texture: texture, color: .clear, size: texture.size())

        self.name = name
        self.physicsBody = SKPhysicsBody(texture: texture, size: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        self.physicsBody?.contactTestBitMask = PhysicsCategory.projectile
        self.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        // Configure the HP bar
        hpBarBackground.position = CGPoint(x: 0, y: size.height / 2 )
        hpBarForeground.position = CGPoint(x: 0, y: size.height / 2 )
        
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
