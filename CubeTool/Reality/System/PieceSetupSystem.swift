//
//  PieceSetupSystem.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/21.
//

import Foundation
import RealityKit
import AppKit
import CoreGraphics

class PieceSetupSystem: System {
    private static let query = EntityQuery(where: .has(PieceComponent.self))
    
    required init(scene: Scene) {
        
    }
    
    
    static let position = [
        SIMD3<Float>(-0.5, 0, 0), // left
        SIMD3<Float>(0.5, 0, 0),  // right
        SIMD3<Float>(0, 0.5, 0),  // up
        SIMD3<Float>(0, -0.5, 0), // down
        SIMD3<Float>(0, 0, 0.5),  // front
        SIMD3<Float>(0, 0, -0.5)  // back
    ]
    static let rotation = [
        simd_quatf(angle: .pi/2 , axis: [0, 0, 1]),     // left
        simd_quatf(angle: -.pi/2 , axis: [0, 0, 1]),    // right
        simd_quatf(angle: 0 , axis: [0, 0, 1]),         // up
        simd_quatf(angle: .pi , axis: [0, 0, 1]),       // down
        simd_quatf(angle: -.pi/2 , axis: [1, 0, 0]),    // front
        simd_quatf(angle: .pi/2 , axis: [1, 0, 0])      // back
    ]

    static let f: CGColor = .init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    static let b: CGColor = .init(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0)
    static let l: CGColor = .init(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
    static let r: CGColor = .init(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0)
    static let u: CGColor = .init(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    static let d: CGColor = .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    static let colorList = [f, b, l, r, u, d]

    
    func update(context: SceneUpdateContext) {
        let entities = context.scene.performQuery(Self.query)
        
        for entity in entities {
            guard var piece = entity.components[PieceComponent.self] else {
                continue
            }
            if piece.setuped {
                continue
            }
            
            let cubeSize: Float = 1.0
            
            var material = PhysicallyBasedMaterial()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .black)
            let center = ModelEntity(
                mesh: MeshResource.generateBox(size: cubeSize),
                materials: [material]
            )
            entity.addChild(center)
            entity.components[CubeRotateComponent.self] = CubeRotateComponent()
            
            // 生成颜色面
            let boxMesh = MeshResource.generateBox(
                width: 0.95 * cubeSize,
                height: 0.04 * cubeSize,
                depth: 0.95 * cubeSize,
                cornerRadius: 0.02
            )
            
            let painteds = [
                // l r u d f b
                piece.index.x == -1,
                piece.index.x == 1,
                piece.index.y == 1,
                piece.index.y == -1,
                piece.index.z == 1,
                piece.index.z == -1
            ]
            
            for (index, painted) in painteds.enumerated() {
                guard painted else { continue }
    
                var color = Self.colorList[index]
                
                // 变灰
                if piece.index.y == 1 && index != 2 {
                    color = .init(gray: 0.3, alpha: 1)
                }
                
                var material = Self.faceMaterial
                material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: NSColor(cgColor: color)!)
                
                
                let faceEntity = ModelEntity(mesh: boxMesh, materials: [material])
                faceEntity.position = Self.position[index] * cubeSize
                faceEntity.transform.rotation = Self.rotation[index]
                faceEntity.name = "face_\(index)"
                entity.addChild(faceEntity)
            }
            
            
            piece.setuped = true
            entity.components[PieceComponent.self] = piece
        }
    }
    
    
    private static let faceMaterial: PhysicallyBasedMaterial = {
        var material = PhysicallyBasedMaterial()
        // 2. 粗糙度 (Roughness)：0.0 是镜面，1.0 是完全磨砂
        material.roughness = 0.2 // 稍微有一点点磨砂质感的塑料感
        // 3. 金属感 (Metallic)：0.0 是非金属（如塑料），1.0 是纯金属
        material.metallic = 0.0 // 魔方通常是塑料材质
        return material
    }()
}


import RealityKit
import simd

// 定义旋转轴
enum RotateAxis {
    case x, y, z
}

//// 扩展你的组件，增加旋转逻辑
//extension PieceComponent {
//    
//    /// 执行旋转
//    /// - Parameters:
//    ///   - axis: 绕哪个轴旋转 (.x, .y, .z)
//    ///   - layer: 旋转哪一层 (-1, 0, 1)。例如绕 X 轴转，1 就是 Right 面，-1 就是 Left 面
//    ///   - isClockwise: 是否顺时针 (按照右手定则，大拇指指向轴正方向)
//    mutating func rotate(axis: RotateAxis, layer: Int, isClockwise: Bool) {
//        
//        // 1. 筛选：如果当前块不在这一层，直接跳过
//        // 例如：我们要转 Right 面 (x=1)，那么 index.x 为 -1 或 0 的块都不动
//        switch axis {
//        case .x: if self.index.x != layer { return }
//        case .y: if self.index.y != layer { return }
//        case .z: if self.index.z != layer { return }
//        }
//        
//        // 2. 准备旋转参数
//        // 角度：90度 = pi/2。顺时针通常是负向，逆时针是正向（视坐标系而定，RealityKit遵循右手定则）
//        // 这里假设 isClockwise 是指“看着轴的正方向”顺时针
//        let angle: Float = isClockwise ? -.pi / 2 : .pi / 2
//        
//        // 3. 更新逻辑坐标 (Index) - 整数数学
//        // 旋转矩阵公式简化版
//        let x = self.index.x
//        let y = self.index.y
//        let z = self.index.z
//        
//        switch axis {
//        case .x:
//            // 绕 X 轴：X 不变，Y 和 Z 交换
//            // 顺时针: (y, z) -> (z, -y)
//            // 逆时针: (y, z) -> (-z, y)
//            if isClockwise {
//                self.index.y = z
//                self.index.z = -y
//            } else {
//                self.index.y = -z
//                self.index.z = y
//            }
//            
//        case .y:
//            // 绕 Y 轴：Y 不变，Z 和 X 交换
//            // 注意 Y 轴旋转的方向判定，通常 (z, x) -> (x, -z) 是顺时针
//            if isClockwise {
//                self.index.z = x
//                self.index.x = -z
//            } else {
//                self.index.z = -x
//                self.index.x = z
//            }
//            
//        case .z:
//            // 绕 Z 轴：Z 不变，X 和 Y 交换
//            if isClockwise {
//                self.index.x = y
//                self.index.y = -x
//            } else {
//                self.index.x = -y
//                self.index.y = x
//            }
//        }
//        
//        // 4. 更新空间姿态 (Orientation) - 四元数乘法
//        // 这一步非常关键！它记录了块的“旋转方向”
//        // 新姿态 = 旋转增量 * 旧姿态 (注意乘法顺序，通常是 左乘增量)
//        
//        let axisVector: SIMD3<Float>
//        switch axis {
//        case .x: axisVector = [1, 0, 0]
//        case .y: axisVector = [0, 1, 0]
//        case .z: axisVector = [0, 0, 1]
//        }
//        
//        let rotationDelta = simd_quatf(angle: angle, axis: axisVector)
//        
//        // 累加旋转。注意：在 RealityKit/Simd 中，通常 q_new = q_delta * q_old
//        // 但如果是在局部坐标系旋转，顺序可能相反。对于魔方这种全局轴旋转，通常是用全局旋转乘当前旋转。
//        self.orientation = rotationDelta * self.orientation
//        
//        // 5. 标记需要重新 Setup (如果你的 System 是每帧检测 setuped 字段)
//        // 实际上，你应该有一个 separate 的 UpdateSystem 来把 component 的 orientation 同步给 entity
//        // self.setuped = false // 如果你需要重新生成模型就设为 false，但通常只需要同步 transform
//    }
//}
