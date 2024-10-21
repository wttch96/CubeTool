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
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()

        // 创建场景
        let scene = SCNScene()
        // scene.background.contents = NSColor.black
//        // 创建X轴 (红色)
//        let xAxis = SCNNode(geometry: SCNCylinder(radius: 0.01, height: 5))
//        xAxis.geometry?.firstMaterial?.diffuse.contents = NSColor.red
//        xAxis.position = SCNVector3(2.5, 0, 0)
//        xAxis.eulerAngles = SCNVector3(0, 0, Float.pi / 2) // 旋转到X轴方向
//
//        // 创建Y轴 (绿色)
//        let yAxis = SCNNode(geometry: SCNCylinder(radius: 0.01, height: 5))
//        yAxis.geometry?.firstMaterial?.diffuse.contents = NSColor.green
//        yAxis.position = SCNVector3(0, 2.5, 0)
//
//        // 创建Z轴 (蓝色)
//        let zAxis = SCNNode(geometry: SCNCylinder(radius: 0.01, height: 5))
//        zAxis.geometry?.firstMaterial?.diffuse.contents = NSColor.blue
//        zAxis.position = SCNVector3(0, 0, 2.5)
//        zAxis.eulerAngles = SCNVector3(Float.pi / 2, 0, 0) // 旋转到Z轴方向
//        // 将轴添加到场景中
//        scene.rootNode.addChildNode(xAxis)
//        scene.rootNode.addChildNode(yAxis)
//        scene.rootNode.addChildNode(zAxis)

        // 创建节点
        for i in 0..<PieceDefinition.all.count {
            var shapeNode = PieceNode(PieceDefinition.all[i])
            let x = i / 9 - 1
            let y = i % 9 / 3 - 1
            let z = i % 9 % 3 - 1
            shapeNode.position = SCNVector3(x * 32, y * 32, z * 32)
            scene.rootNode.addChildNode(shapeNode)
        }
        

        scnView.scene = scene
        // 启用用户交互
        scnView.allowsCameraControl = true

        // 返回 SCNView
        return scnView
    }

    func updateNSView(_ nsView: SCNView, context: Context) {
        // 可以在这里更新视图
    }
}

#Preview {
    CubeView()
}
