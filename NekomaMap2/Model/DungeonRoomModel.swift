

//
//  DungeonRoomModel.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 09/06/24.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0                 // 000000
    static let projectile: UInt32 = 9           // 001001
    static let target: UInt32 = 42              // 101010
    static let player: UInt32 = 18              // 010010
    static let enemy: UInt32 = 32               // 100000
    static let wall: UInt32 = 11                // 001011
    static let enemyProjectile: UInt32 = 24     // 011000
    static let stair: UInt32 = 1
}

enum Direction: String {
    case Up = "Up"
    case Down = "Down"
    case Left = "Left"
    case Right = "Right"
}

// for sorting
let customOrder = ["Up", "Down", "Left", "Right"]

var allDirection = [
    Direction(rawValue: "Left"),
    Direction(rawValue: "Right"),
    Direction(rawValue: "Up"),
    Direction(rawValue: "Down")
]


var allDirectionString = [
    "Left",
    "Right",
    "Up",
    "Down"
]

struct PairInt: Hashable {

    let first: Int
    let second: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.first)
        hasher.combine(self.second)
    }

    static func ==(lhs: PairInt, rhs: PairInt) -> Bool {
        return lhs.first == rhs.first && lhs.second == rhs.second
    }
}

var roomGridSize: CGSize = CGSize(width: 1188, height: 1188)
        
import SpriteKit

class Room: SKSpriteNode {
    var id: Int
    var from: Int
    var to: [Int]?
    var fromDirection: Direction?
    var toDirection: [Direction]?

    init(id: Int, from: Int, to: [Int]? = nil, fromDirection: Direction? = nil, toDirection: [Direction]? = nil, position: CGPoint) {
        self.id = id
        self.from = from
        self.to = to
        self.fromDirection = fromDirection
        self.toDirection = toDirection
        
        super.init(texture: nil, color: .clear, size: CGSize(width: 100, height: 100))
        
        self.position = position
        
        setupRoomImage()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupRoomImage() {
        let (imageName, bgName, _, jailName, jailExtraName) = getRoomImage()
        
        self.texture = SKTexture(imageNamed: imageName)
        self.size = self.texture?.size() ?? CGSize(width: 100, height: 100)
        
        self.name = "Room_\(id)_\(imageName)"
        
        let bgNode = SKSpriteNode(imageNamed: bgName)
        bgNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(bgNode)
        
        let jailNode = SKSpriteNode(imageNamed: jailName)
        jailNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        jailNode.name = "JailNode"
        self.addChild(jailNode)
        
        let jailExtraNode = SKSpriteNode(imageNamed: jailExtraName)
        jailExtraNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        jailExtraNode.name = "JailExtraNode"
        self.addChild(jailExtraNode)
        
    }

    func getRoomImage() -> (imageName: String, bgName: String, imageExtraName: String, jailName: String, jailExtraName: String) {
        var imageName = "Room"
        var bgName = "Bg"
        var imageExtraName = "RoomExtra"
        var jailName = "Jail"
        var jailExtraName = "JailExtra"
        
        var directionStrings = toDirection?.map { $0.rawValue } ?? []
        if let fromDirection = fromDirection {
            directionStrings.append(fromDirection.rawValue)
        }

        directionStrings.sort { direction1, direction2 in
            guard let index1 = customOrder.firstIndex(of: direction1),
                  let index2 = customOrder.firstIndex(of: direction2) else {
                return false
            }
            return index1 < index2
        }
        
        for string in directionStrings {
            imageName.append(string)
            bgName.append(string)
            imageExtraName.append(string)
            jailName.append(string)
            jailExtraName.append(string)
        }

        return (imageName, bgName, imageExtraName, jailName, jailExtraName)
    }
}


