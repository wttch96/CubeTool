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
    // 创建场景
    let scene = SCNScene()
    
    let cubeNode = CubeNode()
    
    func exec(_ moveString: String, action: @escaping () -> Void = {}) {
        let moves = CubeParser.parseMoves(from: moveString)
        cubeNode.executeMoves(moves, action: action)
    }
    
    func performCube(_ cube: Cube) {
        cubeNode.performCube(cube)
    }
    
    func printCube() {
        var pieces: [[[Piece]]] = []
        for x in 0..<3 {
            var xPieces: [[Piece]] = []
            for y in 0..<3 {
                var yPieces: [Piece] = []
                for z in 0..<3 {
                    let node = cubeNode.pieceNodes[x][y][z]
                    let transform = node.orientation
                    let piece = Piece(index: node.index, rotate: .from(transform))
                    yPieces.append(piece)
                }
                xPieces.append(yPieces)
            }
            pieces.append(xPieces)
        }
        let cube = Cube(stickerType: .y2Gray, pieces: pieces)
        let data = try! JSONEncoder().encode(cube)
        print(String(data: data, encoding: .utf8)!)
    }
    
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()
        
        let cubeData = Cube(stickerType: .y2Gray)
        
        addAxis(scene)
        // scene.background.contents = NSColor.black
        
        scene.rootNode.addChildNode(cubeNode)
        
        // 创建摄像机节点
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        // 设置摄像机的位置
        cameraNode.position = SCNVector3(x: 120, y: 120, z: 120)
//        // 设置摄像机的旋转
        cameraNode.orientation = SCNQuaternion(-0.3, 0.35, 0.12, 0.88)
        cameraNode.camera?.zFar = 300
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.scene = scene
        // 启用用户交互
        scnView.allowsCameraControl = true
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleKeyDown(with: event)
            return event
        }
        
        cubeNode.performCube(cubeData)

        // 返回 SCNView
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        // 可以在这里更新视图mm
    }
    
    func handleKeyDown(with event: NSEvent) {
        let cube = cubeNode
        let isShiftPressed = event.modifierFlags.contains(.shift)
        let isOptionPressed = event.modifierFlags.contains(.command)
        switch event.keyCode {
        case 16:
            if isShiftPressed {
                cube.operate(.F(reverse: isOptionPressed))
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
            if isShiftPressed {
                cube.operate(.B(reverse: isOptionPressed))
            } else {
                cube.operate(.b(reverse: isOptionPressed))
            }
        case 3:
            if isShiftPressed {
                cube.operate(.U(reverse: isOptionPressed))
            } else {
                cube.operate(.u(reverse: isOptionPressed))
            }
        case 4:
            if isShiftPressed {
                cube.operate(.D(reverse: isOptionPressed))
            } else {
                cube.operate(.d(reverse: isOptionPressed))
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

extension CubeView {
    private func addAxis(_ scene: SCNScene) {
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
    }
}

#Preview {
    CubeView()
}
