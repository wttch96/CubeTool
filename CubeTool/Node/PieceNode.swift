//
//  PieceNode.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/21.
//

import Foundation
import SceneKit

struct StickerDefinition {
    let color: NSColor
    let topLeftCorner: Bool
    let topRightCorner: Bool
    let bottomLeftCorner: Bool
    let bottomRightCorner: Bool
    
    init(_ color: NSColor, topLeftCorner: Bool = false, topRightCorner: Bool = false, bottomLeftCorner: Bool = false, bottomRightCorner: Bool = false) {
        self.color = color
        self.topLeftCorner = topLeftCorner
        self.topRightCorner = topRightCorner
        self.bottomLeftCorner = bottomLeftCorner
        self.bottomRightCorner = bottomRightCorner
    }
    
    func left() -> Self {
        return .init(color, topLeftCorner: true, topRightCorner: topRightCorner, bottomLeftCorner: true, bottomRightCorner: bottomRightCorner)
    }
    
    func right() -> Self {
        return .init(color, topLeftCorner: topLeftCorner, topRightCorner: true, bottomLeftCorner: bottomLeftCorner, bottomRightCorner: true)
    }
    
    func top() -> Self {
        return .init(color, topLeftCorner: true, topRightCorner: true, bottomLeftCorner: bottomLeftCorner, bottomRightCorner: bottomRightCorner)
    }
    
    func bottom() -> Self {
        return .init(color, topLeftCorner: topLeftCorner, topRightCorner: topRightCorner, bottomLeftCorner: true, bottomRightCorner: true)
    }
    
    func topLeft() -> Self {
        return .init(color, topLeftCorner: true, topRightCorner: topRightCorner, bottomLeftCorner: bottomLeftCorner, bottomRightCorner: bottomRightCorner)
    }
    
    func topRight() -> Self {
        return .init(color, topLeftCorner: topLeftCorner, topRightCorner: true, bottomLeftCorner: bottomLeftCorner, bottomRightCorner: bottomRightCorner)
    }
    
    func bottomLeft() -> Self {
        return .init(color, topLeftCorner: topLeftCorner, topRightCorner: topRightCorner, bottomLeftCorner: true, bottomRightCorner: bottomRightCorner)
    }
    
    func bottomRight() -> Self {
        return .init(color, topLeftCorner: topLeftCorner, topRightCorner: topRightCorner, bottomLeftCorner: bottomLeftCorner, bottomRightCorner: true)
    }
}

class PieceNode: SCNNode {
    let size: CGFloat = 32
    let padding = 2.0
    
    private let stickers: [StickerDefinition?]
    
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
    
    init(_ pieceDefinition: PieceDefinition) {
        guard pieceDefinition.stickers.count == 6 else { fatalError("Invalid sticker count") }
        self.stickers = pieceDefinition.stickers
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
    
    private func createSticker(at position: Int, with sticker: StickerDefinition) {
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
        let centerBox = SCNBox(width: CGFloat(size), height: CGFloat(size), length: CGFloat(size), chamferRadius: 0)
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
