//
//  CubeRotateSystem.swift
//  CubeTool
//
//  Created by Wttch's Mac mini on 2026/1/23.
//

import Foundation
import RealityKit



/// 旋转操作定义
struct Operator {
    let predicate: (Entity, Float) -> Bool
    let axis: SIMD3<Float>
    let clockwise: Bool
    
    struct PositionSelector {
        let select: (Entity) -> Float
        
        static let x = PositionSelector(select: { $0.position.x })
        static let y = PositionSelector(select: { $0.position.y })
        static let z = PositionSelector(select: { $0.position.z })
    }

    private init(predicate: @escaping (Entity, Float) -> Bool, axis: SIMD3<Float>, clockwise: Bool) {
        self.predicate = predicate
        self.axis = axis
        self.clockwise = clockwise
    }
    
    private init(_ selector: PositionSelector, layers: [Int], axis: SIMD3<Float>, clockwise: Bool) {
        self.predicate = { entity, size in
            let pos = selector.select(entity)
            for layer in layers {
                // layer: 0, 1, 2
                // -0.5, 0, 0.5
                if abs(pos - (Float(layer - 1) * size)) <= Operator.shoulder {
                    return true
                }
            }
            return false
        }
        self.axis = axis
        self.clockwise = clockwise
    }
    
    private static let shoulder: Float = 0.1
    
    static let L: Self = .init(.x, layers: [0], axis: [1, 0, 0], clockwise: true)
    static let R: Self = .init(.x, layers: [2], axis: [1, 0, 0], clockwise: false)
    static let U: Self = .init(.y, layers: [2], axis: [0, 1, 0], clockwise: false)
    static let D: Self = .init(.y, layers: [0], axis: [0, 1, 0], clockwise: true)
    static let F: Self = .init(.z, layers: [2], axis: [0, 0, 1], clockwise: false)
    static let B: Self = .init(.z, layers: [0], axis: [0, 0, 1], clockwise: true)
    static let l: Self = .init(.x, layers: [0, 1], axis: [1, 0, 0], clockwise: true)
    static let r: Self = .init(.x, layers: [1, 2], axis: [1, 0, 0], clockwise: false)
    static let u: Self = .init(.y, layers: [1, 2], axis: [0, 1, 0], clockwise: false)
    static let d: Self = .init(.y, layers: [0, 1], axis: [0, 1, 0], clockwise: true)
    static let f: Self = .init(.z, layers: [1, 2], axis: [0, 0, 1], clockwise: false)
    static let b: Self = .init(.z, layers: [0, 1], axis: [0, 0, 1], clockwise: true)
    static let x: Self = .init(.x, layers: [0, 1, 2], axis: [1, 0, 0], clockwise: false)
    static let y: Self = .init(.y, layers: [0, 1, 2], axis: [0, 1, 0], clockwise: false)
    static let z: Self = .init(.z, layers: [0, 1, 2], axis: [0, 0, 1], clockwise: false)
    static let M: Self = .init(.x, layers: [1], axis: [1, 0, 0], clockwise: true)
    static let E: Self = .init(.y, layers: [1], axis: [0, 1, 0], clockwise: true)
    static let S: Self = .init(.z, layers: [1], axis: [0, 0, 1], clockwise: false)
    
    /// 返回一个相反方向的操作
    func reversed() -> Self {
        return Operator(predicate: self.predicate, axis: self.axis, clockwise: !self.clockwise)
    }
}

class CubeRotateSystem: System {
    private static let query = EntityQuery(where: .has(PieceComponent.self))
    private static let cubeOperatoring = EntityQuery(where: .has(CubeRotateComponent.self))
    
    
    var operationQueue: [Operator] = [
        .R, .U.reversed(), .R.reversed(), .U, .y.reversed(), .R.reversed(), .U, .U, .R, .U.reversed(), .U.reversed(), .R.reversed(), .U, .R
    ]
    
    
    required init(scene: Scene) {}
    
    private static func replay(scene: Scene, operators: [Operator]) {
        for op in operators {
            let pieces = scene.performQuery(Self.query)
            let rotateEntity = Entity()
            let size: Float = 1
            pieces.filter { op.predicate($0, size) }
                .forEach { piece in
                    piece.removeFromParent()
                    rotateEntity.addChild(piece)
                }
            scene.findEntity(named: "CubeRoot")?.addChild(rotateEntity)
            // 逆时针?
            let angle: Float = (op.clockwise ? 1 : -1) * .pi / 2
            let rotation = rotateEntity.transform.rotation * simd_quatf(angle: angle, axis: op.axis)
            var transform = rotateEntity.transform
            transform.rotation = rotation
            rotateEntity.move(to: transform, relativeTo: rotateEntity.parent)
            scene.performQuery(Self.query).forEach { entity in
                entity.removeFromParent(preservingWorldTransform: true)
                
                scene.findEntity(named: "CubeRoot")?.addChild(entity)
            }
        }
    }
    
    func update(context: SceneUpdateContext) {
        guard !operationQueue.isEmpty else {
            return
        }
        
        let cube = context.scene.performQuery(Self.cubeOperatoring).first(where: { _ in true })

        guard let cube = cube,
              let rotateComponent = cube.components[CubeRotateComponent.self],
              !rotateComponent.isOperating
        else {
            return
        }
        
        let size: Float = 1
        
        cube.components[CubeRotateComponent.self] = CubeRotateComponent(isOperating: true)
        
        let pieces = context.scene.performQuery(Self.query)
        let op = operationQueue.removeFirst()
        
        print("开始旋转,\(op)")
        let rotateEntity = Entity()
        pieces.filter { op.predicate($0, size) }
            .forEach { piece in
                piece.removeFromParent()
                rotateEntity.addChild(piece)
            }
        cube.addChild(rotateEntity)
        
        // 逆时针?
        let angle: Float = (op.clockwise ? 1 : -1) * .pi / 2
        let rotation = rotateEntity.transform.rotation * simd_quatf(angle: angle, axis: op.axis)
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
