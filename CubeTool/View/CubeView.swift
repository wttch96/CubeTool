//
//  CubeView.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/21.
//

import SceneKit
import SwiftUI

#if os(macOS)
import AppKit

struct CubeView: NSViewRepresentable {
    // 创建场景
    let scene = SCNScene()
    let cubeNode = CubeNode()
    
    init() {
        print("Init CubeView")
        // self.performCube("F2L-00")
    }
    
    func makeNSView(context: Context) -> SCNView {
        let scnView = createSCNView()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleKeyDown(with: event)
            return event
        }
        
        // 返回 SCNView
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {}
    
    func handleKeyDown(with event: NSEvent) {
        let cube = cubeNode
        let isShiftPressed = event.modifierFlags.contains(.shift)
        let isCommandPressed = event.modifierFlags.contains(.command)
        switch event.keyCode {
        case 16:
            if isShiftPressed {
                cube.operate(.F(reverse: isCommandPressed))
            } else {
                cube.operate(.f(reverse: isCommandPressed))
            }
        case 31:
            if isShiftPressed {
                cube.operate(.R(reverse: isCommandPressed))
            } else {
                cube.operate(.r(reverse: isCommandPressed))
            }
        case 35:
            if isShiftPressed {
                cube.operate(.L(reverse: isCommandPressed))
            } else {
                cube.operate(.l(reverse: isCommandPressed))
            }
        case 45:
            if isShiftPressed {
                cube.operate(.B(reverse: isCommandPressed))
            } else {
                cube.operate(.b(reverse: isCommandPressed))
            }
        case 3:
            if isShiftPressed {
                cube.operate(.U(reverse: isCommandPressed))
            } else {
                cube.operate(.u(reverse: isCommandPressed))
            }
        case 4:
            if isShiftPressed {
                cube.operate(.D(reverse: isCommandPressed))
            } else {
                cube.operate(.d(reverse: isCommandPressed))
            }
        case 46:
            cube.operate(.M(reverse: isShiftPressed))
        case 2:
            cube.operate(.E(reverse: isShiftPressed))
        case 41:
            cube.operate(.S(reverse: isShiftPressed))
        case 11:
            cube.operate(.x(reverse: isShiftPressed))
        case 17:
            cube.operate(.y(reverse: isShiftPressed))
        case 44:
            cube.operate(.z(reverse: isShiftPressed))
        default:
            print(event.keyCode)
        }
    }
}

#endif

#if os(iOS)
struct CubeView: UIViewRepresentable {
    // 创建场景
    let scene = SCNScene()
    let cubeNode = CubeNode()
    
    func makeUIView(context: Context) -> some UIView {
        let scnView = createSCNView()
        // 返回 SCNView
        return scnView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
#endif

extension CubeView {
    #if os(iOS)
    private var xAxisColor: UIColor {
        UIColor.systemRed
    }

    private var yAxisColor: UIColor {
        UIColor.systemGreen
    }

    private var zAxisColor: UIColor {
        UIColor.systemBlue
    }
    #endif
    #if os(macOS)
    private var xAxisColor: NSColor {
        NSColor.systemRed
    }

    private var yAxisColor: NSColor {
        NSColor.systemGreen
    }

    private var zAxisColor: NSColor {
        NSColor.systemBlue
    }
    #endif
    
    private func createSCNView() -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.antialiasingMode = .multisampling4X
        
        addCamera(scene)
        addAxis(scene)
        scene.rootNode.addChildNode(cubeNode)
        
        scnView.scene = scene
        // 启用用户交互
        scnView.allowsCameraControl = true
        
        return scnView
    }
    
    private func addCamera(_ scene: SCNScene) {
        // 创建摄像机节点
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        // 设置摄像机的位置
        cameraNode.position = SCNVector3(x: 120, y: 120, z: 120)
        // 设置摄像机的旋转
        cameraNode.orientation = SCNQuaternion(-0.3, 0.35, 0.12, 0.88)
        cameraNode.camera?.zFar = 300
        scene.rootNode.addChildNode(cameraNode)
    }
    
    private func addAxis(_ scene: SCNScene) {
        // 创建X轴 (红色)
        let xAxis = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 200))
        xAxis.geometry?.firstMaterial?.diffuse.contents = xAxisColor
        xAxis.position = SCNVector3(2.5, 0, 0)
        xAxis.eulerAngles = SCNVector3(0, 0, Float.pi / 2) // 旋转到X轴方向
        
        // 创建Y轴 (绿色)
        let yAxis = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 200))
        yAxis.geometry?.firstMaterial?.diffuse.contents = yAxisColor
        yAxis.position = SCNVector3(0, 2.5, 0)
        
        // 创建Z轴 (蓝色)
        let zAxis = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 200))
        zAxis.geometry?.firstMaterial?.diffuse.contents = zAxisColor
        zAxis.position = SCNVector3(0, 0, 2.5)
        zAxis.eulerAngles = SCNVector3(Float.pi / 2, 0, 0) // 旋转到Z轴方向
        // 将轴添加到场景中
        scene.rootNode.addChildNode(xAxis)
        scene.rootNode.addChildNode(yAxis)
        scene.rootNode.addChildNode(zAxis)
        
        // 显示 F 箭头
        // 围绕 x 轴画半圆线段
        let tube = SCNTube(innerRadius: 54, outerRadius: 55, height: 2)
        
        
        let arrowNode = SCNNode(
            geometry: tube
        )
        arrowNode.geometry?.firstMaterial?.diffuse.contents = xAxisColor
        arrowNode.position = SCNVector3(102, 0, 0)
        arrowNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        scene.rootNode.addChildNode(arrowNode)
    }
    
    func exec(_ moveString: String, duration: Double, action: @escaping () -> Void = {}) {
        let moves = CubeParser.parseMoves(from: moveString)
        cubeNode.executeMoves(moves, duration: duration, action: action)
    }
    
    func performCube(_ named: String) {
        if let cube = Cube(systemName: named) {
            cubeNode.performCube(cube)
        }
    }
    
    func printCube() {
        cubeNode.printCube()
    }
}

#Preview {
    CubeView()
}
