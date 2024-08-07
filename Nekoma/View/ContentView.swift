//
//  ContentView.swift
//  NekomaMap2
//
//  Created by Jennifer Luvindi on 09/06/24.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @Binding var isGameOver: Bool
    @Binding var isVictory: Bool
    
    var scene: SKScene {
        let scene = DungeonScene(isGameOver: $isGameOver, isVictory: $isVictory)
        scene.scaleMode = .resizeFill
        return scene
    }
    
    var body: some View {
        SpriteView(scene: scene)
            .edgesIgnoringSafeArea(.all)
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
