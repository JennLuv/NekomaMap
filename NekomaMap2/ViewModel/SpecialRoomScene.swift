//
//  SaveCatScene.swift
//  NekomaMap2
//
//  Created by Brendan Alexander Soendjojo on 25/06/24.
//

import SpriteKit
import SwiftUI

class SpecialRoomScene: DungeonScene2 {
    override init(isGameOver: Binding<Bool>) {
        super.init(isGameOver: isGameOver)
        print("SPECIAL ROOM SCENE")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        guard !didMoveCompleted else { return }  // Prevent multiple calls
        didMoveCompleted = true
        print("Did Move")
        super.didMove(to: view)
        setupScene()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
    }

    override func didBegin(_ contact: SKPhysicsContact) {
        super.didBegin(contact)
        let contactA = contact.bodyA.categoryBitMask
        let contactB = contact.bodyB.categoryBitMask
        
        if (contactA == PhysicsCategory.player && contactB == PhysicsCategory.stair) ||
           (contactA == PhysicsCategory.stair && contactB == PhysicsCategory.player) {
            DungeonStateManager.shared.transitionBackToDungeon(from: self)
        }
    }
    
    func setupScene() {
        drawSpecialDungeon()
        addStairNode(at: CGPoint(x: 0, y: 30))
    }

    func addStairNode(at position: CGPoint) {
        let stair = SKSpriteNode(imageNamed: "stair")
        stair.name = "stair"
        stair.position = position
        stair.size = CGSize(width: 50, height: 50)
        stair.physicsBody = SKPhysicsBody(rectangleOf: stair.size)
        stair.physicsBody?.isDynamic = false
        stair.physicsBody?.usesPreciseCollisionDetection = true
        stair.physicsBody?.categoryBitMask = PhysicsCategory.stair
        stair.physicsBody?.collisionBitMask = PhysicsCategory.none
        stair.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(stair)
    }
}
