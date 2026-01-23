//
//  CubeRotateSystem.swift
//  CubeTool
//
//  Created by Wttch's Mac mini on 2026/1/23.
//

import Foundation
import RealityKit

/// 旋转操作定义
struct 魔方操作 {
    let 条件: (Entity, Float) -> Bool
    let 轴: SIMD3<Float>
    let 顺时针: Bool
}

class CubeRotateSystem: System {
    private static let query = EntityQuery(where: .has(PieceComponent.self))
    
    private var selectedPieces: [Entity] = []
    
    var operationQueue: [String] = []
    var isOperating: Bool = false
    
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let pieces = context.scene.performQuery(Self.query)
        guard !isOperating, let operation = operationQueue.first else {
            return
        }
        
        // 选择
        let selectedPieces = pieces.filter { $0.position.x >= 0 }
        // 旋转轴
        let rotateAxis = SIMD3<Float>(1, 0, 0)
        // 逆时针?
        let angle: Float = -.pi / 2
        
        isOperating = true
        // 旋转动画
        
        // 旋转动画
        for piece in selectedPieces {
            let rotation = piece.transform.rotation * simd_quatf(angle: angle, axis: rotateAxis)
            var transform = piece.transform
            transform.rotation = rotation
            piece.move(to: transform , relativeTo: nil, duration: 0.5, timingFunction: .easeInOut)
            // 动画完成后，更新状态
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.isOperating = false
        })
        
    }
}

extension CubeRotateSystem {
    func L() {}
    
    func R() {}
}

// R
// x 1 逆时针
