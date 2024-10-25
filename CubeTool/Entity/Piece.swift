//
//  Piece.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/24.
//

import Foundation

// MARK: Piece

/// 魔方块定义
/// 从 x 轴正向向负向看去, 为 R 面
/// 从 y 轴正向向负向看去, 为 U 面
/// 从 z 轴正向向负向看去, 为 F 面
struct Piece: Codable {
    // 当前块的索引
    let index: IntVector3

    // 当前的旋转情况
    let rotate: IntVector3
}

struct IntVector3: Codable {
    let x: Int
    let y: Int
    let z: Int
}

extension IntVector3 {
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(x: x, y: y, z: z)
    }
}
