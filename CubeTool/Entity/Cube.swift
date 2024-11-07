//
//  Cube.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/23.
//

// MARK: Cube

import Foundation

/// 魔方的保存格式
struct Cube: Codable {
    /// 魔方的贴图
    let stickerType: CubeStateType

    /// 魔方块定义
    let pieces: [[[Piece]]]
}

extension Cube {
    /// 初始化魔方
    init(stickerType: CubeStateType) {
        self.stickerType = stickerType

        var pieces = Array(repeating: Array(repeating: Array(repeating: Piece.zero, count: 3), count: 3), count: 3)
        for x in 0..<3 {
            for y in 0..<3 {
                for z in 0..<3 {
                    pieces[x][y][z] = Piece(index: .init(x, y, z), rotate: .zero)
                }
            }
        }
        self.pieces = pieces
    }

    /// 从系统资源初始化魔方
    init?(systemName: String) {
        guard let url = Bundle.main.url(forResource: systemName, withExtension: "json") else {
            return nil
        }
        self.init(contentsOf: url)
    }

    /// 从 URL 初始化魔方
    init?(contentsOf: URL) {
        guard let data = try? Data(contentsOf: contentsOf) else { return nil }
        guard let cube = try? JSONDecoder().decode(Cube.self, from: data) else { return nil }
        self = cube
    }
}
