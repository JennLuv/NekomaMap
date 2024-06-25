//
//  DungeonStateManager.swift
//  NekomaMap2
//
//  Created by Brendan Alexander Soendjojo on 25/06/24.
//

import SpriteKit

class DungeonStateManager {
    static let shared = DungeonStateManager()
    
    private init() {}
    
    private var savedState: [String: Any] = [:]
    private var previousDungeonScene: DungeonScene2?

    func saveState(from scene: DungeonScene2) {
        var state: [String: Any] = [:]
        state["playerPosition"] = NSValue(cgPoint: scene.player.position)
        state["currentRoomNum"] = scene.currentRoomNum
        // Add other elements you want to save (enemies, chests, etc.)
        savedState = state
        previousDungeonScene = scene
    }

    func restoreState(to scene: DungeonScene2) {
        if let playerPosition = savedState["playerPosition"] as? CGPoint {
            scene.player.position = playerPosition
        }
        if let currentRoomNum = savedState["currentRoomNum"] as? Int {
            scene.currentRoomNum = currentRoomNum
        }
        // Restore other elements (enemies, chests, etc.)
    }

    func transitionToSpecialRoom(from scene: DungeonScene2) {
        print("TRANSITION")
        saveState(from: scene)
        let specialRoomScene = SpecialRoomScene(isGameOver: scene.$isGameOver)
        let transition = SKTransition.fade(withDuration: 1.0)
        scene.view?.presentScene(specialRoomScene, transition: transition)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            scene.isTransitioning = false
            scene.didMoveCompleted = false
        } // Reset the flag after transitioning
    }

    func transitionBackToDungeon(from scene: SpecialRoomScene) {
        guard let previousDungeonScene = previousDungeonScene else { return }
        restoreState(to: previousDungeonScene)
        let transition = SKTransition.fade(withDuration: 1.0)
        scene.view?.presentScene(previousDungeonScene, transition: transition)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            previousDungeonScene.isTransitioning = false
            previousDungeonScene.didMoveCompleted = false
        }
    }
}
