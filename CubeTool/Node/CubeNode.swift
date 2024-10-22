//
//  CubeNode.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/22.
//

import Foundation
import SceneKit

class CubeNode: SCNNode {
    let pieces: [PieceDefinition]
    var positios: [[[Int]]]
    
    private var pieceNodes: [[[PieceNode]]] = []
    
    private var isRotating: Bool = false

    init(_ positios: [[[Int]]] = [
        [[0, 1, 2], [3, 4, 5], [6, 7, 8]],
        [[9, 10, 11], [12, 13, 14], [15, 16, 17]],
        [[18, 19, 20], [21, 22, 23], [24, 25, 26]]
    ], pieces: [PieceDefinition] = PieceDefinition.all) {
        self.pieces = pieces
        self.positios = positios

        super.init()

        // 初始化块

        // 创建节点
        for x in 0..<3 {
            var xPieces: [[PieceNode]] = []
            for y in 0..<3 {
                var yPieces: [PieceNode] = []
                for z in 0..<3 {
                    let index = positios[x][y][z]
                    let shapeNode = PieceNode(PieceDefinition.all[index])
                    shapeNode.position = SCNVector3((x-1) * Constants.size, (y-1) * Constants.size, (z-1) * Constants.size)
                    addChildNode(shapeNode)
                    yPieces.append(shapeNode)
                }
                xPieces.append(yPieces)
            }
            pieceNodes.append(xPieces)
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
        
        wrapNode.runAction(createRotateAction(
            rotateAction: SCNAction.rotate(by: CGFloat.pi / 2, around: op.around, duration: 0.2),
            pieceIndexAction: SCNAction.run { _ in
                // 调整块形态
                for (node, index) in zip(nodes, op.pieceNextIndex) {
                    let (x, y, z) = op.pieceIndex[index]
                    self.pieceNodes[x][y][z] = node
                }
            })
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 旋转动画

extension CubeNode {
    /// 创建旋转动画
    /// - Parameters:
    ///  - rotateAction: 旋转动画
    ///  - pieceIndexAction: 调整块索引的动画
    private func createRotateAction(rotateAction: SCNAction, pieceIndexAction: SCNAction) -> SCNAction {
        return SCNAction.sequence([
            rotateAction,
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
            pieceIndexAction,
            rotateEnd()
        ])
    }
    /// 结束旋转
    private func rotateEnd() -> SCNAction {
        return SCNAction.run { _ in
            self.isRotating = false
        }
    }
}
