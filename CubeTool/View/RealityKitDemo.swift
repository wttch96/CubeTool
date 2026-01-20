//
//  RealityKitDemo.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/18.
//

import RealityKit
import SwiftUI

struct RealityKitDemo: View {
    
    // 1. 创建相机实体
    let camera = PerspectiveCamera()
    
    let cubeEntity = ModelEntity()
    var body: some View {
        RealityView { content in
            
            var cubeEntity = Entity(components: [
                PieceColorComponent(
                    l: .orange,
                    r: .blue,
                    u: .yellow,
                    f: .red,
                )
            ])
            
            content.add(cubeEntity)
            
            // 添加三个轴
            let axisLength: Float = 3
            let axisThickness: Float = 0.05
            let xAxis = ModelEntity(
                mesh: MeshResource.generateBox(size: [axisLength, axisThickness, axisThickness]),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            xAxis.position = [axisLength / 2, 0, 0]
            cubeEntity.addChild(xAxis)
            let yAxis = ModelEntity(
                mesh: MeshResource.generateBox(size: [axisThickness, axisLength, axisThickness]),
                materials: [SimpleMaterial(color: .green, isMetallic: false)]
            )
            yAxis.position = [0, axisLength / 2, 0]
            cubeEntity.addChild(yAxis)
            let zAxis = ModelEntity(
                mesh: MeshResource.generateBox(size: [axisThickness, axisThickness, axisLength]),
                materials: [SimpleMaterial(color: .blue, isMetallic: false)]
            )
            zAxis.position = [0, 0, axisLength / 2]
            cubeEntity.addChild(zAxis)

            // 2. 设置位置并看向原点
            // position: 相机所在位置 [1, 1, 1]
            // target: 目标位置 [0, 0, 0]
            let cameraPosition: SIMD3<Float> = [2, 2, 2]
            let targetPosition: SIMD3<Float> = [0.0, 0.0, 0.0]

            camera.look(at: targetPosition, from: cameraPosition, relativeTo: nil)

            // 3. 将相机添加到场景中
            // 在 RealityKit 中，必须将相机添加到一个锚点或直接添加到内容中
            content.add(camera)
            // ceamera 围绕 原点旋转
            
            // cubeEntity.transform.rotation = IntVector4(1000, 1000, 0, 10000).toSimdQuatf()
        }
        .onTapGesture {
            camera.move(to: Transform(translation: [2, 2, 2]), relativeTo: camera.parent, duration: 1)
        }
        .gesture(DragGesture().onChanged { value in
            let width = value.translation.width
            // Rotate around Z axis (Roll)
            let angle = Float(width / 2000)

            var transform = cubeEntity.transform

            transform.rotation *= simd_quatf(angle: angle, axis: [0, 1, 0])

            cubeEntity.transform = transform
        })
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
        let cubeSize: Float = 1
        // 六个面的位置
        let position = [
            SIMD3<Float>(-0.5, 0, 0), // left
            SIMD3<Float>(0.5, 0, 0), // right
            SIMD3<Float>(0, 0.5, 0), // up
            SIMD3<Float>(0, -0.5, 0), // down
            SIMD3<Float>(0, 0, 0.5), // front
            SIMD3<Float>(0, 0, -0.5) // back
        ].map { $0 * cubeSize }
        
        // 六个面的旋转角度
        let rotation = [
            simd_quatf(angle: .pi / 2, axis: [0, 0, 1]), // left
            simd_quatf(angle: -.pi / 2, axis: [0, 0, 1]), // right
            simd_quatf(angle: 0, axis: [0, 0, 1]), // up
            simd_quatf(angle: .pi, axis: [0, 0, 1]), // down
            simd_quatf(angle: -.pi / 2, axis: [1, 0, 0]), // front
            simd_quatf(angle: .pi / 2, axis: [1, 0, 0]) // back
        ]
        // 中心块
        var material = PhysicallyBasedMaterial()
        material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: .black)
        let cubeEntity = ModelEntity(
            mesh: MeshResource.generateBox(size: cubeSize),
            materials: [material]
        )
        // 循环生成六个面
        for i in 0 ..< 6 {
            guard let color = colors[i] else { continue }
            let boxMesh = MeshResource.generateBox(
                width: 0.95 * cubeSize,
                height: 0.04 * cubeSize,
                depth: 0.95 * cubeSize,
                cornerRadius: 0.02
            )
            
            var material = Self.faceMaterial
            material.baseColor = PhysicallyBasedMaterial.BaseColor(tint: NSColor(color))
            
            let faceEntity = ModelEntity(mesh: boxMesh, materials: [material])
            faceEntity.position = position[i]
            faceEntity.transform.rotation = rotation[i]
            faceEntity.name = "face_\(i)"
            cubeEntity.addChild(faceEntity)
        }
        
        return cubeEntity
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

#Preview {
    RealityKitDemo()
        .onAppear {
            PieceColorComponent.registerComponent()
            PieceColorSystem.registerSystem()
        }
}
