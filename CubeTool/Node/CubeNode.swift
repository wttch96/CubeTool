//
//  CubeNode.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/22.
//

import Foundation
import SceneKit

class CubeNode: SCNNode {
    var pieceNodes: [[[PieceNode]]] = []
    
    private var isRotating: Bool = false

    override init() {
        super.init()
        self.name = "Cube"
    }
    
    func performCube(_ cube: Cube) {
        pieceNodes = []
        childNodes.forEach { $0.removeFromParentNode() }
        
        // 创建节点
        for x in 0..<3 {
            var xPieces: [[PieceNode]] = []
            for y in 0..<3 {
                var yPieces: [PieceNode] = []
                for z in 0..<3 {
                    let piece = cube.pieces[x][y][z]
                    let index = piece.index.x * 9 + piece.index.y * 3 + piece.index.z
                    let shapeNode = PieceNode(cube.stickerType.pieces[index], index: IntVector3(x, y, z))
                    shapeNode.position = SCNVector3((x-1) * Constants.size, (y-1) * Constants.size, (z-1) * Constants.size)
                    addChildNode(shapeNode)
                    shapeNode.orientation = piece.rotate.toSCNQuaternion()
                    yPieces.append(shapeNode)
                }
                xPieces.append(yPieces)
            }
            pieceNodes.append(xPieces)
        }
    }
    
    func executeMoves(_ moves: [CubeMove], current: Int = 0) {
        guard current < moves.count else { return }
        
        let moveOperator: [CubeMove: CubeOperator] = [
            .F: .F(),
            .F_prime: .F(reverse: true),
            .f: .f(),
            .f_prime: .f(reverse: true),
            .B: .B(),
            .B_prime: .B(reverse: true),
            .b: .b(),
            .b_prime: .b(reverse: true),
            .U: .U(),
            .U_prime: .U(reverse: true),
            .u: .u(),
            .u_prime: .u(reverse: true),
            .D: .D(),
            .D_prime: .D(reverse: true),
            .d: .d(),
            .d_prime: .d(reverse: true),
            .L: .L(),
            .L_prime: .L(reverse: true),
            .l: .l(),
            .l_prime: .l(reverse: true),
            .R: .R(),
            .R_prime: .R(reverse: true),
            .r: .r(),
            .r_prime: .r(reverse: true),
            .M: .M(),
            .M_prime: .M(reverse: true),
            .E: .E(),
            .E_prime: .E(reverse: true),
            .S: .S(),
            .S_prime: .S(reverse: true),
            .x: .x(),
            .x_prime: .x(reverse: true),
            .y: .y(),
            .y_prime: .y(reverse: true),
            .z: .z(),
            .z_prime: .z(reverse: true)
        ]
        let op = moveOperator[moves[current]]!
        print("开始执行:\(moves[current])")
        
        guard !isRotating else { return }
        isRotating = true
        
        var nodes: [PieceNode] = []
        let wrapNode = SCNNode()
        
        for (x, y, z) in op.pieceIndex {
            let node = pieceNodes[x][y][z]
            nodes.append(node)
            wrapNode.addChildNode(node)
        }
        
        addChildNode(wrapNode)
        let action = SCNAction.sequence([
            SCNAction.rotate(by: CGFloat.pi / 2, around: op.around.toSCNVector3(), duration: 0.2),
            SCNAction.run { node in
                for child in node.childNodes {
                    // 获取子节点在世界坐标系中的旋转
                    let worldOrientation = node.convertTransform(child.transform, to: self)
                
                    // 将子节点从父节点中移除并添加到场景根节点中
                    child.removeFromParentNode()
                    self.addChildNode(child)
                
                    // 应用世界坐标系中的旋转
                    child.transform = worldOrientation
                }
                node.removeFromParentNode()
            },
            SCNAction.run { _ in
                // 调整块形态
                for (node, index) in zip(nodes, op.pieceNextIndex) {
                    // 下一个位置
                    let (x, y, z) = op.pieceIndex[index]
                    self.pieceNodes[x][y][z] = node
                    // 修改数据状态
                }
            },
            SCNAction.run { _ in
                self.isRotating = false
            }
        ])
        wrapNode.runAction(action) {
            print("结束执行:\(moves[current])")
            DispatchQueue.main.async {
                self.executeMoves(moves, current: current + 1)
            }
        }
    }
    
    func operate(_ op: CubeOperator) {
        guard !isRotating else { return }
        isRotating = true
        
        var nodes: [PieceNode] = []
        let wrapNode = SCNNode()
        
        for (x, y, z) in op.pieceIndex {
            let node = pieceNodes[x][y][z]
            nodes.append(node)
            wrapNode.addChildNode(node)
        }
        
        addChildNode(wrapNode)
        let action = SCNAction.sequence([
            SCNAction.rotate(by: CGFloat.pi / 2, around: op.around.toSCNVector3(), duration: 0.2),
            SCNAction.run { node in
                for child in node.childNodes {
                    // 获取子节点在世界坐标系中的旋转
                    let worldOrientation = node.convertTransform(child.transform, to: self)
                
                    // 将子节点从父节点中移除并添加到场景根节点中
                    child.removeFromParentNode()
                    self.addChildNode(child)
                
                    // 应用世界坐标系中的旋转
                    child.transform = worldOrientation
                }
                node.removeFromParentNode()
            },
            SCNAction.run { _ in
                // 调整块形态
                for (node, index) in zip(nodes, op.pieceNextIndex) {
                    let (x, y, z) = op.pieceIndex[index]
                    self.pieceNodes[x][y][z] = node
                }
            },
            SCNAction.run { _ in
                self.isRotating = false
            }
        ])
        wrapNode.runAction(action)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
