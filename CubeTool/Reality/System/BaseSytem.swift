//
//  BaseSytem.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/24.
//

import RealityKit

class BaseSystem: System {
    let scene: Scene
    required init(scene: Scene) {
        self.scene = scene
    }
    
    func update(context: SceneUpdateContext) {
        
    }
}


extension BaseSystem {
    var cubeRoot: Entity? {
        return scene.findEntity(named: "CubeRoot")
    }
}
