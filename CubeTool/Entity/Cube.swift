//
//  Cube.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/23.
//

// MARK: Cube

/// 魔方的保存格式
struct Cube: Codable {
    /// 魔方的贴图
    let stickerType: CubeStickerType

    /// 魔方块定义
    let pieces: [[[Piece]]]
}

/// 魔方贴图类型
enum CubeStickerType: String, Codable {
    /// 正常的魔方贴图
    case normal
    /// U 面全为灰色
    case y2Gray
    /// U 面为白色, 四周为灰色
    case topWhite

    var pieces: [Pieces] {
        switch self {
        case .normal:
            Pieces.all
        case .y2Gray:
            Pieces.y2Gray
        case .topWhite:
            Pieces.topWhite
        }
    }
}
