//
//  PieceColorSystem.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/20.
//

import Foundation
import RealityKit
import AppKit

class PieceColorSystem: System {
    private static let query = EntityQuery(where: .has(PieceColorComponent.self))
    
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
    
    
    func update(context: SceneUpdateContext) {
        let pieces = context.scene.performQuery(Self.query)
        for piece in pieces {
            guard var colorComponent = piece.components[PieceColorComponent.self] else {
                continue
            }
            if colorComponent.generaed { continue }
            
            let cubeSize = colorComponent.size
            
            var material = PhysicallyBasedMaterial()
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .black)
            let center = ModelEntity(
                mesh: MeshResource.generateBox(size: cubeSize),
                materials: [material]
            )
            piece.addChild(center)
            
            // 生成颜色面
            let colors = [colorComponent.left,
                          colorComponent.right,
                          colorComponent.up,
                          colorComponent.down,
                          colorComponent.front,
                          colorComponent.back]
            let boxMesh = MeshResource.generateBox(
                width: 0.95 * cubeSize,
                height: 0.04 * cubeSize,
                depth: 0.95 * cubeSize,
                cornerRadius: 0.02
            )
            
            for (index, color) in colors.enumerated() {
                guard let color = color else { continue }
    
                
                var material = Self.faceMaterial
                material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: NSColor(color))
                
                
                let faceEntity = ModelEntity(mesh: boxMesh, materials: [material])
                faceEntity.position = Self.position[index] * cubeSize
                faceEntity.transform.rotation = Self.rotation[index]
                faceEntity.name = "face_\(index)"
                piece.addChild(faceEntity)
            }
            
            colorComponent.generaed = true
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
