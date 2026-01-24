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
    
    static let moveMap: [CubeMove: Self] = [
        .L: .L,
        .L_prime: .L.reversed(),
        .R: .R,
        .R_prime: .R.reversed(),
        .U: .U,
        .U_prime: .U.reversed(),
        .D: .D,
        .D_prime: .D.reversed(),
        .F: .F,
        .F_prime: .F.reversed(),
        .B: .B,
        .B_prime: .B.reversed(),
        .l: .l,
        .l_prime: .l.reversed(),
        .r: .r,
        .r_prime: .r.reversed(),
        .u: .u,
        .u_prime: .u.reversed(),
        .d: .d,
        .d_prime: .d.reversed(),
        .f: .f,
        .f_prime: .f.reversed(),
        .b: .b,
        .b_prime: .b.reversed(),
        .x: .x,
        .x_prime: .x.reversed(),
        .y: .y,
        .y_prime: .y.reversed(),
        .z: .z,
        .z_prime: .z.reversed(),
        .M: .M,
        .M_prime: .M.reversed(),
        .E: .E,
        .E_prime: .E.reversed(),
        .S: .S,
    ]
    
    /// 返回一个相反方向的操作
    func reversed() -> Self {
        return Operator(predicate: predicate, axis: axis, clockwise: !clockwise)
    }
}

class CubeRotateSystem: BaseSystem {
    private static let query = EntityQuery(where: .has(PieceComponent.self))
    private static let cubeOperatoring = EntityQuery(where: .has(CubeRotateComponent.self))
    private var controll: AnimationPlaybackController? = nil
    
    /// 执行一个旋转操作
    private func performOpeartor(_ move: CubeMove, duration: TimeInterval? = nil, moveEnd: (() -> Void)? = nil) {
        print("开始执行操作:\(move)")
        let pieces = scene.performQuery(Self.query)
        let rotateEntity = Entity()
        let size: Float = 1
        let op = Operator.moveMap[move]!
        pieces.filter { op.predicate($0, size) }
            .forEach { piece in
                piece.removeFromParent()
                rotateEntity.addChild(piece)
            }
        cubeRoot?.addChild(rotateEntity)
        // 逆时针?
        let angle: Float = (op.clockwise ? 1 : -1) * .pi / 2
        let rotation = rotateEntity.transform.rotation * simd_quatf(angle: angle, axis: op.axis)
        var transform = rotateEntity.transform
        transform.rotation = rotation
        if let duration = duration {
            controll = rotateEntity.move(to: transform, relativeTo: rotateEntity.parent, duration: duration, timingFunction: .easeInOut)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.05) {
                self.resetPieceRelation()
                moveEnd?()
                print("操作\(move)结束")
            }
        } else {
            rotateEntity.move(to: transform, relativeTo: rotateEntity.parent)
            resetPieceRelation()
            print("操作\(move)结束")
        }
    }
    
    /// 重置魔方块的父子关系
    private func resetPieceRelation() {
        for entity in scene.performQuery(Self.query) {
            entity.removeFromParent(preservingWorldTransform: true)
            
            scene.findEntity(named: "CubeRoot")?.addChild(entity)
        }
    }
    
    /// 重放一系列操作
    func replay(operators: [CubeMove]) {
        for op in operators {
            performOpeartor(op)
            
            resetPieceRelation()
        }
    }
    
    override func update(context: SceneUpdateContext) {
        // 重放和旋转
        guard let cubeRoot = cubeRoot else { return }
        guard var rotateComponent = cubeRoot.components[CubeRotateComponent.self] else { return }
        
        if rotateComponent.immediate {
            // 开始重放
            replay(operators: rotateComponent.operators)
            cubeRoot.components[CubeRotateComponent.self] = CubeRotateComponent()
            print("已恢复状态")
            return
        }
        
        guard !rotateComponent.operators.isEmpty else {
            return
        }
        guard !rotateComponent.isOperating else {
            return
        }
        
        
        rotateComponent.isOperating = true
        var operators = rotateComponent.operators
        let nextOp = operators.removeFirst()
        rotateComponent.operators = operators
        
        performOpeartor(nextOp, duration: 0.5, moveEnd: {
            // 重置 bug
            guard var rotateComponent = cubeRoot.components[CubeRotateComponent.self] else
            {
                return
            }
            rotateComponent.isOperating = false
            cubeRoot.components[CubeRotateComponent.self] = rotateComponent
        })
        cubeRoot.components[CubeRotateComponent.self] = rotateComponent
    }
}
