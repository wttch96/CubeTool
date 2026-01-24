//
//  CubeSetupSystem.swift
//  CubeTool
//
//  Created by Wttch's Mac mini on 2026/1/24.
//

import RealityKit
class CubeSetupSystem: System {
    required init(scene: Scene) {
        
    }
    
    func update(context: SceneUpdateContext) {
        // 初始化
        let cubeRoot = context.scene.findEntity(named: "CubeRoot")
        if let cubeRoot = cubeRoot,
            var replayComponent = cubeRoot.components[CubeReplayComponent.self],
           let _ = replayComponent.formula,
           !replayComponent.inited
        {
            // 开始重放
            cubeRoot.children.forEach { cubeRoot.removeChild($0) }
            for i in -1...1 {
                for j in -1...1 {
                    for k in -1...1 {
                        let piece = Entity()
                        piece.position = SIMD3<Float>([i, j, k])

                        piece.components.set(PieceComponent(index: [i, j, k]))
                        cubeRoot.addChild(piece)
                    }
                }
            }
            replayComponent.inited = true
            cubeRoot.components.set(replayComponent)
            print("魔方已初始化...")
        }
    }
}
