import RealityKit
import SwiftUI

struct RealityKitDemo: View {
    // 1. [修复] 使用 @State 保持实体的生命周期引用
    @State private var cubeEntity = Entity()
    
    // 2. [建议] 相机也可以作为一个 Entity 管理，或者保持现状
    private let camera = PerspectiveCamera()
    
    @State private var cubes: [Entity] = []

    // 3. [修复] 在 init 中注册组件，确保 App 运行时也能生效
    init() {
        // 为了防止重复注册导致 Crash，RealityKit 内部会自动处理，
        // 但最佳实践是写个单例或静态标记。这里简单写在 init 里。
        PieceComponent.registerComponent()
        CubeRotateComponent.registerComponent()
        PieceSetupSystem.registerSystem()
        CubeRotateSystem.registerSystem()
        CubeSetupSystem.registerSystem()
        // PieceColorSystem.registerSystem() // 如果你有颜色系统也加上
    }
    
    /// 制定一个面旋转90度
    func rotateFace90Degrees() {
        // 这里可以实现旋转逻辑
        // 例如，选择一个面上的所有 PieceComponent，然后应用旋转变换
        
    }

    var body: some View {
        RealityView { content in
            // --- 场景构建 ---
            
            
            // B. 添加辅助轴 (Visual Debugging)
            addDebugAxes(to: cubeEntity)

            // C. 设置相机
            let cameraPosition: SIMD3<Float> = [4, 4, 4] // 稍微拉远一点，防止贴脸
            let targetPosition: SIMD3<Float> = [0, 0, 0]
            camera.look(at: targetPosition, from: cameraPosition, relativeTo: nil)
            content.add(camera)
            
            // D. 将根节点加入场景
            
            cubeEntity.components[CubeReplayComponent.self] = CubeReplayComponent(formula: "")
            cubeEntity.components[CubeRotateComponent.self] = CubeRotateComponent(isOperating: false)
            cubeEntity.name = "CubeRoot"
            content.add(cubeEntity)
            
        }
        .onTapGesture {
            // [修复] 解开注释，实现旋转逻辑
            
            // 1. 获取当前变换 (基于 @State 的实体)
            var targetTransform = cubeEntity.transform
            
            // 2. 计算增量旋转 (绕 Y 轴 90 度)
            // 注意：使用乘法来叠加旋转
            let rotationDelta = simd_quatf(angle: .pi / 2, axis: [0, 1, 0])
            targetTransform.rotation = targetTransform.rotation * rotationDelta
            
            // 3. 执行动画
            cubeEntity.move(
                to: targetTransform,
                relativeTo: nil,
                duration: 0.5, // 1秒略慢，0.5秒比较跟手
                timingFunction: .easeInOut
            )
        }
        .onAppear {
            
            if let url = Bundle.main.url(forResource: "Formula", withExtension: "json") {
                let jsonData = try! Data(contentsOf: url)
                let decoder = JSONDecoder()
                let formulas = try! decoder.decode(Formula.self, from: jsonData)
                print(formulas)
            }
        }
    }
    
    // 辅助函数：添加坐标轴
    private func addDebugAxes(to parent: Entity) {
        let axisLength: Float = 3
        let thickness: Float = 0.05
        
        func createAxis(size: SIMD3<Float>, color: NSColor, pos: SIMD3<Float>) -> ModelEntity {
            let mesh = MeshResource.generateBox(size: size)
            let material = SimpleMaterial(color: color, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.position = pos
            return entity
        }
        
        parent.addChild(createAxis(size: [axisLength, thickness, thickness], color: .red, pos: [axisLength/2, 0, 0]))   // X
        parent.addChild(createAxis(size: [thickness, axisLength, thickness], color: .green, pos: [0, axisLength/2, 0])) // Y
        parent.addChild(createAxis(size: [thickness, thickness, axisLength], color: .blue, pos: [0, 0, axisLength/2]))  // Z
    }
}

#Preview {
    RealityKitDemo()
}
