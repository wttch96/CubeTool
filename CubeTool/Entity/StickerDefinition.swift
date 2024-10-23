//
//  StickerDefinition.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/22.
//
import AppKit

/// 贴图定义
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
    
    func center() -> Self {
        return .init(color, topLeftCorner: true, topRightCorner: true, bottomLeftCorner: true, bottomRightCorner: true)
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
    
}
