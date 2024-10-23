//
//  Piece.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/23.
//

import Foundation

/// 魔方块定义
/// 从 x 轴正向向负向看去, 为 R 面
/// 从 y 轴正向向负向看去, 为 U 面
/// 从 z 轴正向向负向看去, 为 F 面
struct Piece {
    let stickerIndex: Int

    // 当前所在位置的坐标
    let x: Int
    let y: Int
    let z: Int

    // 当前的旋转情况
    let xAngle: Int
    let yAngle: Int
    let zAngle: Int
}
