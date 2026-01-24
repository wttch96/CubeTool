//
//  CubeInitSystem.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/24.
//
import RealityKit
import AppKit
import SwiftLogMacro


/// 魔方初始化
@Log()
class CubeInitSystem: BaseSystem {
    override func update(context: SceneUpdateContext) {
        guard let cubeRoot = cubeRoot else {
            self.logger.error("未找到魔方根节点")
            return
        }
        guard var initComponent = cubeRoot.components[CubeInitComponent.self] else {
            self.logger.error("魔方根节点缺少CubeInitComponent组件")
            return
        }
        guard !initComponent.inited else { return }
       
        
        self.logger.info("开始初始化魔方...")
        cubeRoot.children.forEach { cubeRoot.removeChild($0) }
        for i in -1...1 {
            for j in -1...1 {
                for k in -1...1 {
                    let piece = Entity()
                    // 染色
                    paintedPiece(piece, index: [i, j, k])
                    
                    cubeRoot.addChild(piece)
                }
            }
        }
        // 染色
        
        initComponent.inited = true
        cubeRoot.components.set(initComponent)
        cubeRoot.components.set(
            CubeRotateComponent(
                isOperating: false,
                operators:  CubeParser.parseMoves(from: initComponent.formula ?? ""),
                immediate: true
            )
        )
        self.logger.info("魔方已初始化.")
    }
    
    func paintedPiece(_ piece: Entity, index: SIMD3<Int>) {
        let cubeSize: Float = 1.0
        
        piece.position = SIMD3<Float>(index) * cubeSize
        
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .black.withAlphaComponent(0.5))
        let center = ModelEntity(
            mesh: MeshResource.generateBox(size: cubeSize),
            materials: [material]
        )
        piece.addChild(center)
        piece.components.set(PieceComponent(index: index))
        piece.components[CubeRotateComponent.self] = CubeRotateComponent()
        
        // 生成颜色面
        let boxMesh = MeshResource.generateBox(
            width: 0.95 * cubeSize,
            height: 0.04 * cubeSize,
            depth: 0.95 * cubeSize,
            cornerRadius: 0.02
        )
        
        let painteds = [
            // l r u d f b
            index.x == -1,
            index.x == 1,
            index.y == 1,
            index.y == -1,
            index.z == 1,
            index.z == -1
        ]
        
        for (i, painted) in painteds.enumerated() {
            guard painted else { continue }

            var color = Self.colorList[i]
            
            // 根据魔方变灰
            if index.y == 1 /*&& index != 2*/ {
                color = .init(gray: 0.3, alpha: 1)
            }
            
            var material = Self.faceMaterial
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: NSColor(cgColor: color)!)
            
            
            let faceEntity = ModelEntity(mesh: boxMesh, materials: [material])
            faceEntity.position = Self.position[i] * cubeSize
            faceEntity.transform.rotation = Self.rotation[i]
            faceEntity.name = "face_\(index)"
            piece.addChild(faceEntity)
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

}


