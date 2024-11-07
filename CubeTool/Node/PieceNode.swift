//
//  PieceNode.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/21.
//

import Foundation
import SceneKit

class PieceNode: SCNNode {
    let padding = 2.0
    
    private let stickers: [StickerDefinition?]
    
    var index: IntVector3
    
    // F, B, L, R, U, D
    private let positions: [SCNVector3] = [
        SCNVector3(0, 0, 0.5),
        SCNVector3(0, 0, -0.5),
        SCNVector3(-0.5, 0, 0),
        SCNVector3(0.5, 0, 0),
        SCNVector3(0, 0.5, 0),
        SCNVector3(0, -0.5, 0)
    ]
    private let rotates: [SCNVector3] = [
        SCNVector3(0, 0, 0),
        SCNVector3(0, 0, -Float.pi),
        SCNVector3(0, -Float.pi / 2, 0),
        SCNVector3(0, Float.pi / 2, 0),
        SCNVector3(Float.pi / 2, 0, 0),
        SCNVector3(-Float.pi / 2, 0, 0)
    ]
    
    init(_ pieceDefinition: Pieces, index: IntVector3) {
        guard pieceDefinition.stickers.count == 6 else { fatalError("Invalid sticker count") }
        self.stickers = pieceDefinition.stickers
        self.index = index
        super.init()
        
        createPiece()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createPiece() {
        createCenterBox()
        
        for i in 0 ..< 6 {
            if let sticker = stickers[i] {
                createSticker(at: i, with: sticker)
            }
        }
    }
}

#if os(iOS)
extension PieceNode {
    private func createSticker(at position: Int, with sticker: StickerDefinition) {
        let size = CGFloat(Constants.size)
        let fSize = Float(size)
        let stickerSize = size - padding
        let cornerSize = stickerSize * 0.3
        let path = UIBezierPath.init(roundedRect: CGRect(x: -stickerSize / 2, y: -stickerSize / 2, width: stickerSize, height: stickerSize), cornerRadius: 4)
        let shape = SCNShape(path: path, extrusionDepth: 0.01)
        let node = SCNNode(geometry: shape)
        node.geometry?.firstMaterial?.diffuse.contents = sticker.color
        node.position = SCNVector3(positions[position].x * fSize, positions[position].y * fSize, positions[position].z * fSize)
        node.eulerAngles = rotates[position]
        addChildNode(node)
    }
    
    private func createCenterBox() {
        let size = CGFloat(Constants.size)
        let centerBox = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        centerBox.firstMaterial?.diffuse.contents = UIColor.black
        let boxNode = SCNNode(geometry: centerBox)
        addChildNode(boxNode)
    }
}

#endif

#if os(macOS)

extension PieceNode {
    private func createSticker(at position: Int, with sticker: StickerDefinition) {
        let size = CGFloat(Constants.size)
        let stickerSize = size - padding
        let cornerSize = stickerSize * 0.3
        let path = NSBezierPath.roundedRect(
            rect: CGRect(x: -stickerSize / 2, y: -stickerSize / 2, width: stickerSize, height: stickerSize),
            topLeftRadius: sticker.topLeftCorner ? cornerSize : 0,
            topRightRadius: sticker.topRightCorner ? cornerSize : 0,
            bottomLeftRadius: sticker.bottomLeftCorner ? cornerSize : 0,
            bottomRightRadius: sticker.bottomRightCorner ? cornerSize : 0
        )
        let shape = SCNShape(path: path, extrusionDepth: 0.01)
        let node = SCNNode(geometry: shape)
        node.geometry?.firstMaterial?.diffuse.contents = sticker.color
        node.position = SCNVector3(positions[position].x * size, positions[position].y * size, positions[position].z * size)
        node.eulerAngles = rotates[position]
        addChildNode(node)
    }
    
    private func createCenterBox() {
        let size = CGFloat(Constants.size)
        let centerBox = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
        centerBox.firstMaterial?.diffuse.contents = NSColor.black
        let boxNode = SCNNode(geometry: centerBox)
        addChildNode(boxNode)
    }
}

extension NSBezierPath {
    // 创建一个圆角矩形，四个角分别指定不同的圆角半径
    static func roundedRect(rect: CGRect, topLeftRadius: CGFloat, topRightRadius: CGFloat, bottomLeftRadius: CGFloat, bottomRightRadius: CGFloat) -> NSBezierPath {
        let path = NSBezierPath()
        
        // 矩形的顶点
        let topLeft = CGPoint(x: rect.minX, y: rect.maxY)
        let topRight = CGPoint(x: rect.maxX, y: rect.maxY)
        let bottomRight = CGPoint(x: rect.maxX, y: rect.minY)
        let bottomLeft = CGPoint(x: rect.minX, y: rect.minY)
        
        // 移动到左上角，准备开始绘制
        path.move(to: CGPoint(x: topLeft.x + topLeftRadius, y: topLeft.y))
        
        // 绘制从左上角到右上角的线，并添加右上角圆角
        path.line(to: CGPoint(x: topRight.x - topRightRadius, y: topRight.y))
        path.appendArc(from: CGPoint(x: topRight.x, y: topRight.y), to: CGPoint(x: topRight.x, y: topRight.y - topRightRadius), radius: topRightRadius)
        
        // 绘制从右上角到右下角的线，并添加右下角圆角
        path.line(to: CGPoint(x: bottomRight.x, y: bottomRight.y + bottomRightRadius))
        path.appendArc(from: CGPoint(x: bottomRight.x, y: bottomRight.y), to: CGPoint(x: bottomRight.x - bottomRightRadius, y: bottomRight.y), radius: bottomRightRadius)
        
        // 绘制从右下角到左下角的线，并添加左下角圆角
        path.line(to: CGPoint(x: bottomLeft.x + bottomLeftRadius, y: bottomLeft.y))
        path.appendArc(from: CGPoint(x: bottomLeft.x, y: bottomLeft.y), to: CGPoint(x: bottomLeft.x, y: bottomLeft.y + bottomLeftRadius), radius: bottomLeftRadius)
        
        // 绘制从左下角到左上角的线，并添加左上角圆角
        path.line(to: CGPoint(x: topLeft.x, y: topLeft.y - topLeftRadius))
        path.appendArc(from: CGPoint(x: topLeft.x, y: topLeft.y), to: CGPoint(x: topLeft.x + topLeftRadius, y: topLeft.y), radius: topLeftRadius)
        
        // 闭合路径
        path.close()
        
        return path
    }
}
#endif
