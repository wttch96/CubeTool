//
//  CubeOperator.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/22.
//

import Foundation
import SceneKit

struct CubeOperator {
    var pieceIndex: [(x: Int, y: Int, z: Int)]
    var pieceNextIndex: [Int]
    var around: SCNVector3

    init(pieceIndex: [(x: Int, y: Int, z: Int)], clockwise: Bool, around: SCNVector3) {
        self.pieceIndex = pieceIndex
        self.pieceNextIndex = if clockwise {
            [
                2, 5, 8,
                1, 4, 7,
                0, 3, 6
            ]
        } else {
            [
                6, 3, 0,
                7, 4, 1,
                8, 5, 2
            ]
        }
        self.around = around
    }

    private static let FPieceIndex: [(x: Int, y: Int, z: Int)] = [
        (0, 2, 2), (1, 2, 2), (2, 2, 2),
        (0, 1, 2), (1, 1, 2), (2, 1, 2),
        (0, 0, 2), (1, 0, 2), (2, 0, 2)
    ]

    // F 操作
    static func F(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: FPieceIndex,
            clockwise: clockwise,
            around: SCNVector3(0, 0, clockwise ? -1 : 1)
        )
    }

    private static let RPieceIndex: [(x: Int, y: Int, z: Int)] = [
        (2, 2, 2), (2, 2, 1), (2, 2, 0),
        (2, 1, 2), (2, 1, 1), (2, 1, 0),
        (2, 0, 2), (2, 0, 1), (2, 0, 0)
    ]

    // R 操作
    static func R(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: RPieceIndex,
            clockwise: clockwise,
            around: SCNVector3(clockwise ? -1 : 1, 0, 0)
        )
    }

    // L 操作
    static func L(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: [
                (0, 2, 0), (0, 2, 1), (0, 2, 2),
                (0, 1, 0), (0, 1, 1), (0, 1, 2),
                (0, 0, 0), (0, 0, 1), (0, 0, 2)
            ],
            clockwise: clockwise,
            around: SCNVector3(clockwise ? 1 : -1, 0, 0)
        )
    }

    // B 操作
    static func B(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: [
                (2, 2, 0), (1, 2, 0), (0, 2, 0),
                (2, 1, 0), (1, 1, 0), (0, 1, 0),
                (2, 0, 0), (1, 0, 0), (0, 0, 0)
            ],
            clockwise: clockwise,
            around: SCNVector3(0, 0, clockwise ? 1 : -1)
        )
    }

    // U 操作
    static func U(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: [
                (0, 2, 0), (1, 2, 0), (2, 2, 0),
                (0, 2, 1), (1, 2, 1), (2, 2, 1),
                (0, 2, 2), (1, 2, 2), (2, 2, 2)
            ],
            clockwise: clockwise,
            around: SCNVector3(0, clockwise ? -1 : 1, 0)
        )
    }

    // D 操作
    static func D(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: [
                (0, 0, 2), (1, 0, 2), (2, 0, 2),
                (0, 0, 1), (1, 0, 1), (2, 0, 1),
                (0, 0, 0), (1, 0, 0), (2, 0, 0)
            ],
            clockwise: clockwise,
            around: SCNVector3(0, clockwise ? 1 : -1, 0)
        )
    }
}
