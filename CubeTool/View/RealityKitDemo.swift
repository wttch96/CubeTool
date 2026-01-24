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
        CubeRotateComponent.registerComponent()
        CubeInitComponent.registerComponent()
        PieceComponent.registerComponent()
        CubeRotateSystem.registerSystem()
        CubeInitSystem.registerSystem()
    }
    
    /// 制定一个面旋转90度
    func rotateFace90Degrees() {
        // 这里可以实现旋转逻辑
        // 例如，选择一个面上的所有 PieceComponent，然后应用旋转变换
        
    }

    var body: some View {
        RealityView { content in
            // --- 场景构建 ---
            
            cubeEntity.components[CubeInitComponent.self] = CubeInitComponent(formula: "(RU'R'U)y'(R'U2RU'2)(R'UR)")
            cubeEntity.components[CubeRotateComponent.self] = CubeRotateComponent(isOperating: false)
            cubeEntity.name = "CubeRoot"
            content.add(cubeEntity)
            
            // B. 添加辅助轴 (Visual Debugging)
            addDebugAxes(to: content)
            
            // C. 设置相机
            let cameraPosition: SIMD3<Float> = [4, 4, 4] // 稍微拉远一点，防止贴脸
            let targetPosition: SIMD3<Float> = [0, 0, 0]
            camera.look(at: targetPosition, from: cameraPosition, relativeTo: nil)
            content.add(camera)
            
            
        }
        .onTapGesture {
            cubeEntity.components[CubeRotateComponent.self] = CubeRotateComponent(
                isOperating: false,
                operators: [.R, .U, .R_prime, .U_prime],
                immediate: false
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
    private func addDebugAxes(to parent: RealityViewCameraContent) {
        let axisLength: Float = 3
        let thickness: Float = 0.05
        
        func createAxis(size: SIMD3<Float>, color: NSColor, pos: SIMD3<Float>) -> ModelEntity {
            let mesh = MeshResource.generateBox(size: size)
            let material = SimpleMaterial(color: color, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.position = pos
            return entity
        }
        
        parent.add(createAxis(size: [axisLength, thickness, thickness], color: .red, pos: [axisLength/2, 0, 0]))   // X
        parent.add(createAxis(size: [thickness, axisLength, thickness], color: .green, pos: [0, axisLength/2, 0])) // Y
        parent.add(createAxis(size: [thickness, thickness, axisLength], color: .blue, pos: [0, 0, axisLength/2]))  // Z
    }
}

#Preview {
    RealityKitDemo()
}
