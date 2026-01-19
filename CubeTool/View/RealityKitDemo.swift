//
//  RealityKitDemo.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/18.
//

import RealityKit
import SwiftUI

struct RealityKitDemo: View {

    let entity1 = createCube(l: .gray, r: .gray, u: .blue, d: .green, f: nil, b: nil)
    
    var body: some View {
        RealityView { content in

            
            content.add(entity1)
            
            // 1. 创建相机实体
            let camera = PerspectiveCamera()

            // 2. 设置位置并看向原点
            // position: 相机所在位置 [1, 1, 1]
            // target: 目标位置 [0, 0, 0]
            let cameraPosition: SIMD3<Float> = [1.0, 1.0, 1.0]
            let targetPosition: SIMD3<Float> = [0.0, 0.0, 0.0]

            camera.look(at: targetPosition, from: cameraPosition, relativeTo: nil)

            // 3. 将相机添加到场景中
            // 在 RealityKit 中，必须将相机添加到一个锚点或直接添加到内容中
            content.add(camera)
            // ceamera 围绕 原点旋转
        }
        .onTapGesture {
            
            startInfiniteRotation(entity: entity1)
        }
    }
    func startInfiniteRotation(entity: Entity) {
        // 创建一个从当前状态旋转 360 度的变换
        var transform = entity.transform
        transform.rotation *= simd_quatf(angle: .pi, axis: [0, 0, 1])
        
        // 开启动画
        entity.move(to: transform,
                    relativeTo: entity.parent,
                    duration: 2.0,
                    timingFunction: .linear)
        
        // 在 2026 年，RealityKit 支持动画链式调用或重复监听
        // 动画结束后再次触发即可实现循环
    }
}

extension RealityKitDemo {
    // 根据六个面的颜色创建一个CubeEntity
    private static func createCube(l: Color?, r: Color?, u: Color?, d: Color?, f: Color?, b: Color?) -> ModelEntity {
        // 使用六个 BoxMesh 和一个中心块拼接成
        let colors = [l, r, u, d, f, b]
        let position = [
            SIMD3<Float>(-0.5, 0, 0), // left
            SIMD3<Float>(0.5, 0, 0),  // right
            SIMD3<Float>(0, 0.5, 0),  // up
            SIMD3<Float>(0, -0.5, 0), // down
            SIMD3<Float>(0, 0, 0.5),  // front
            SIMD3<Float>(0, 0, -0.5)  // back
        ]
        let rotation = [
            simd_quatf(angle: .pi/2 , axis: [0, 0, 1]), // left
            simd_quatf(angle: -.pi/2 , axis: [0, 0, 1]), // right
            simd_quatf(angle: 0 , axis: [0, 0, 1]), // up
            simd_quatf(angle: .pi , axis: [0, 0, 1]), // down
            simd_quatf(angle: -.pi/2 , axis: [1, 0, 0]), // front
            simd_quatf(angle: .pi/2 , axis: [1, 0, 0])  // back
        ]
        
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .black)
        let cubeEntity = ModelEntity(
            mesh: MeshResource.generateBox(size: 1.0),
            materials: [material]
        )
        
        for i in 0..<6 {
            guard let color = colors[i] else { continue }
            let boxMesh = MeshResource.generateBox(width: 0.95, height: 0.1, depth: 0.95, cornerRadius: 0.05)
            var material = PhysicallyBasedMaterial()
            
            // 2. 粗糙度 (Roughness)：0.0 是镜面，1.0 是完全磨砂
            material.roughness = 0.2 // 稍微有一点点磨砂质感的塑料感

            // 3. 金属感 (Metallic)：0.0 是非金属（如塑料），1.0 是纯金属
            material.metallic = 0.0 // 魔方通常是塑料材质
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: NSColor(color))
            let faceEntity = ModelEntity(mesh: boxMesh, materials: [material])
            faceEntity.position = position[i]
            faceEntity.transform.rotation = rotation[i]
            faceEntity.name = "face_\(i)"
            cubeEntity.addChild(faceEntity)
        }
        
        return cubeEntity
    }
}

#Preview {
    RealityKitDemo()
}
