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
    static var cube: CubeNode? = nil
    
    func exec(_ moveString: String) {
        let moves = CubeParser.parseMoves(from: moveString)
        CubeView.cube?.executeMoves(moves)
    }
    
    private func angle(_ angle: CGFloat) -> Int {
        var angle = Int(angle / .pi * 2)
        if angle < -1 {
            angle += 4
        }
        if angle >= 3 {
            angle -= 4
        }
        return angle
    }
    
    func printCube() {
        var pieces: [[[Piece]]] = []
        for x in 0..<3 {
            var xPieces: [[Piece]] = []
            for y in 0..<3 {
                var yPieces: [Piece] = []
                for z in 0..<3 {
                    let node = CubeView.cube!.pieceNodes[x][y][z]
                    let piece = Piece(index: node.index, rotate: IntVector3(x: angle(node.eulerAngles.x), y: angle(node.eulerAngles.y), z: angle(node.eulerAngles.z)))
                    yPieces.append(piece)
                }
                xPieces.append(yPieces)
            }
            pieces.append(xPieces)
        }
        let cube = Cube(stickerType: .y2Gray, pieces: pieces)
        let data = try! JSONEncoder().encode(cube)
        try! data.write(to: URL(fileURLWithPath: "/Users/wttch/Desktop/cube.json"))
    }
    
    func makeNSView(context: Context) -> SCNView {
        let scnView = SCNView()
        
        let cubeData = try! JSONDecoder().decode(Cube.self, from: Data(contentsOf: Bundle.main.url(forResource: "cube", withExtension: "json")!))
        print(cubeData)
        
        
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
        let cube = CubeNode(cubeData)
        scene.rootNode.addChildNode(cube)
        
        // 创建摄像机节点
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        // 设置摄像机的位置
        cameraNode.position = SCNVector3(x: 120, y: 120, z: 120)
//        // 设置摄像机的旋转
        cameraNode.eulerAngles = SCNVector3(-CGFloat.pi / 5, CGFloat.pi / 4, 0)
        cameraNode.camera?.zFar = 300
        scene.rootNode.addChildNode(cameraNode)
        
        scnView.scene = scene
        // 启用用户交互
        scnView.allowsCameraControl = true
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleKeyDown(with: event, cube: cube)
            return event
        }
        
        DispatchQueue.main.async(execute: {
            CubeView.cube = cube
            print("Set Cube")
        })

        // 返回 SCNView
        return scnView
    }
    
    func updateNSView(_ nsView: SCNView, context: Context) {
        // 可以在这里更新视图mm
    }
    
    func handleKeyDown(with event: NSEvent, cube: CubeNode) {
        guard let cube = CubeView.cube else { return }
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

#Preview {
    CubeView()
}
