//
//  PieceView.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/21.
//

import AppKit
import SceneKit
import SwiftUI

struct CubeView: NSViewRepresentable {
    let cube = CubeNode()
    
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()
        
        // 创建场景
        let scene = SCNScene()
        // scene.background.contents = NSColor.black
        // 创建X轴 (红色)
        let xAxis = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 200))
        xAxis.geometry?.firstMaterial?.diffuse.contents = NSColor.red
        xAxis.position = SCNVector3(2.5, 0, 0)
        xAxis.eulerAngles = SCNVector3(0, 0, Float.pi / 2) // 旋转到X轴方向
        
        // 创建Y轴 (绿色)
        let yAxis = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 200))
        yAxis.geometry?.firstMaterial?.diffuse.contents = NSColor.green
        yAxis.position = SCNVector3(0, 2.5, 0)
        
        // 创建Z轴 (蓝色)
        let zAxis = SCNNode(geometry: SCNCylinder(radius: 0.5, height: 200))
        zAxis.geometry?.firstMaterial?.diffuse.contents = NSColor.blue
        zAxis.position = SCNVector3(0, 0, 2.5)
        zAxis.eulerAngles = SCNVector3(Float.pi / 2, 0, 0) // 旋转到Z轴方向
        // 将轴添加到场景中
        scene.rootNode.addChildNode(xAxis)
        scene.rootNode.addChildNode(yAxis)
        scene.rootNode.addChildNode(zAxis)
        
        scene.rootNode.addChildNode(cube)
        
        scnView.scene = scene
        // 启用用户交互
        scnView.allowsCameraControl = true
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleKeyDown(with: event)
            return event
        }
        
        // 返回 SCNView
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        // 可以在这里更新视图mm
    }
    
    func handleKeyDown(with event: NSEvent) {
        let isShiftPressed = event.modifierFlags.contains(.shift)
        let isOptionPressed = event.modifierFlags.contains(.command)
        switch event.keyCode {
        case 16:
            if isShiftPressed {
                cube.operate(.F(clockwise: !isOptionPressed))
            } else {
                cube.operate(.f(reverse: isOptionPressed))
            }
        case 31:
            if isShiftPressed {
                cube.operate(.R(reverse: isOptionPressed))
            } else {
                cube.operate(.r(reverse: isOptionPressed))
            }
        case 35:
            if isShiftPressed {
                cube.operate(.L(reverse: isOptionPressed))
            } else {
                cube.operate(.l(reverse: isOptionPressed))
            }
        case 45:
            cube.operate(.B(clockwise: !isShiftPressed))
        case 3:
            cube.operate(.U(clockwise: !isShiftPressed))
        case 4:
            cube.operate(.D(clockwise: !isShiftPressed))
        case 46:
            cube.operate(.M(reverse: isShiftPressed))
        case 2:
            cube.operate(.E(clockwise: !isShiftPressed))
        case 41:
            cube.operate(.S(clockwise: !isShiftPressed))
        case 11:
            cube.operate(.x(reverse: isShiftPressed))
        default:
            print(event.keyCode)
        }
    }
}

#Preview {
    CubeView()
}
