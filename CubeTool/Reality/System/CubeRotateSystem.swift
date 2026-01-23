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
    
    private init(_ 条件: @escaping (Entity, Float) -> Bool, _ 轴: SIMD3<Float>, _ 顺时针: Bool) {
        self.条件 = 条件
        self.轴 = 轴
        self.顺时针 = 顺时针
    }
    
    static let L: Self = .init({ $0.position.x <= $1 * -0.5 }, SIMD3<Float>(-1, 0, 0), true)
}

class CubeRotateSystem: System {
    private static let query = EntityQuery(where: .has(PieceComponent.self))
    private static let cubeOperatoring = EntityQuery(where: .has(CubeRotateComponent.self))
    
    private var selectedPieces: [Entity] = []
    
    var operationQueue: [String] = []
    
    required init(scene: Scene) {}
    
    func update(context: SceneUpdateContext) {
        let cube = context.scene.performQuery(Self.cubeOperatoring).first(where: { _ in true })

        guard let cube = cube,
              let rotateComponent = cube.components[CubeRotateComponent.self],
              !rotateComponent.isOperating
        else {
            return
        }
        
        print("开始旋转")
        cube.components[CubeRotateComponent.self] = CubeRotateComponent(isOperating: true)
        
        // 临时旋转集合
        let rotateEntity = Entity()
        
        let pieces = context.scene.performQuery(Self.query)
        
        cube.addChild(rotateEntity)
        
        let size: Float = 1
        // 选择
        pieces.filter { 魔方操作.L.条件($0, size) }
            .forEach { piece in
            piece.removeFromParent()
            rotateEntity.addChild(piece)
        }
        
        
        
        // 旋转轴
        let rotateAxis = SIMD3<Float>(1, 0, 0)
        // 逆时针?
        let angle: Float = -.pi / 2
        
        // 旋转动画
        
        let rotation = rotateEntity.transform.rotation * simd_quatf(angle: angle, axis: rotateAxis)
        var transform = rotateEntity.transform
        transform.rotation = rotation
        rotateEntity.move(to: transform, relativeTo: rotateEntity.parent, duration: 0.5, timingFunction: .easeInOut)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            //
            context.scene.performQuery(Self.query).forEach { entity in
                entity.removeFromParent(preservingWorldTransform: true)
                
                context.scene.findEntity(named: "CubeRoot")?.addChild(entity)
            }
            
            cube.components[CubeRotateComponent.self] = CubeRotateComponent(isOperating: false)
            print("旋转结束")
        }
    }
}

extension CubeRotateSystem {
    func L() {}
    
    func R() {}
}

// R
// x 1 逆时针
