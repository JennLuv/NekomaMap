//
//  DungeonRoomModel.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 09/06/24.
//

import Foundation

struct PhysicsCategory {
    static let none: UInt32 = 0                 // 000
    static let projectile: UInt32 = 8           // 1000
    static let target: UInt32 = 10              // 1010
    static let player: UInt32 = 6               // 0110
    static let enemy: UInt32 = 8                // 1000
    static let wall: UInt32 = 11
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

class Room {
    var id: Int
    
    var from: Int
    var to: [Int]?
    
    var fromDirection: Direction?
    var toDirection: [Direction]?
    
    var position: CGPoint
    
    
    func getRoomImage() -> (imageName: String, bgName: String, imageExtraName: String, jailName: String, jailExtraName: String) {
        var imageName: String = "Room"
        var bgName: String = "Bg"
        var imageExtraName: String = "RoomExtra"
        var jailName: String = "Jail"
        var jailExtraName: String = "JailExtra"
        
        var directionStrings = toDirection?.map { $0.rawValue } ?? []
        
        if fromDirection != nil {
            directionStrings.append((fromDirection?.rawValue)!)
        }
        
        directionStrings.sort { direction1, direction2 in
            guard let index1 = customOrder.firstIndex(of: direction1),
                  let index2 = customOrder.firstIndex(of: direction2) else {
                return false // if any direction is not found in the custom order, maintain the original order
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
    
    init(id: Int, from: Int, to: [Int]? = nil, fromDirection: Direction? = nil, toDirection: [Direction]? = nil, position: CGPoint) {
        self.id = id
        self.from = from
        self.to = to
        self.fromDirection = fromDirection
        self.toDirection = toDirection
        self.position = position
    }
}
