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

    init(pieceIndex: [(x: Int, y: Int, z: Int)], pieceNextIndex: [Int], around: SCNVector3) {
        self.pieceIndex = pieceIndex
        self.pieceNextIndex = pieceNextIndex
        self.around = around
    }

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

    private static func reverseLayer(layer x: [(x: Int, y: Int, z: Int)]) -> [(x: Int, y: Int, z: Int)] {
        return [
            x[2], x[1], x[0],
            x[5], x[4], x[3],
            x[8], x[7], x[6]
        ]
    }

    private static let x0: [(x: Int, y: Int, z: Int)] = [
        (0, 2, 2), (0, 2, 1), (0, 2, 0),
        (0, 1, 2), (0, 1, 1), (0, 1, 0),
        (0, 0, 2), (0, 0, 1), (0, 0, 0)
    ]

    private static let x0_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: x0)

    private static let x1: [(x: Int, y: Int, z: Int)] = [
        (1, 2, 2), (1, 2, 1), (1, 2, 0),
        (1, 1, 2), (1, 1, 1), (1, 1, 0),
        (1, 0, 2), (1, 0, 1), (1, 0, 0)
    ]

    private static let x1_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: x1)

    private static let x2: [(x: Int, y: Int, z: Int)] = [
        (2, 2, 2), (2, 2, 1), (2, 2, 0),
        (2, 1, 2), (2, 1, 1), (2, 1, 0),
        (2, 0, 2), (2, 0, 1), (2, 0, 0)
    ]

    private static let x2_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: x2)

    private static let FPieceIndex: [(x: Int, y: Int, z: Int)] = [
        (0, 2, 2), (1, 2, 2), (2, 2, 2),
        (0, 1, 2), (1, 1, 2), (2, 1, 2),
        (0, 0, 2), (1, 0, 2), (2, 0, 2)
    ]

    private static func nextIndex(_ reverse: Bool) -> [Int] {
        // 这里: 比如 reverse 0
        // 说明 右上角 -> 0 即转到左上角
        if reverse {
            // 6, 3, 0
            // 7, 4, 1
            // 8, 5, 2
            return [6, 3, 0, 7, 4, 1, 8, 5, 2]
        } else {
            // 2, 5, 8
            // 1, 4, 7
            // 0, 3, 6
            return [2, 5, 8, 1, 4, 7, 0, 3, 6]
        }
    }

    private static func layer2NextIndex(_ reverse: Bool) -> [Int] {
        let layer1Index = nextIndex(reverse)
        var result = layer1Index
        for index in layer1Index {
            result.append(index + 9)
        }
        return result
    }

    private static func layer3NextIndex(_ reverse: Bool) -> [Int] {
        let layer1Index = nextIndex(reverse)
        var result = layer1Index
        for index in layer1Index {
            result.append(index + 9)
        }
        for index in layer1Index {
            result.append(index + 18)
        }
        return result
    }

    // F 操作
    static func F(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: FPieceIndex,
            clockwise: clockwise,
            around: SCNVector3(0, 0, clockwise ? -1 : 1)
        )
    }

    // f 操作
    static func f(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: [
                (0, 2, 1), (1, 2, 1), (2, 2, 1),
                (0, 1, 1), (1, 1, 1), (2, 1, 1),
                (0, 0, 1), (1, 0, 1), (2, 0, 1),
                (0, 2, 2), (1, 2, 2), (2, 2, 2),
                (0, 1, 2), (1, 1, 2), (2, 1, 2),
                (0, 0, 2), (1, 0, 2), (2, 0, 2)
            ],
            pieceNextIndex: layer2NextIndex(reverse),
            around: SCNVector3(0, 0, reverse ? 1 : -1)
        )
    }

    private static let RPieceIndex: [(x: Int, y: Int, z: Int)] = [
        (2, 2, 2), (2, 2, 1), (2, 2, 0),
        (2, 1, 2), (2, 1, 1), (2, 1, 0),
        (2, 0, 2), (2, 0, 1), (2, 0, 0)
    ]

    // R 操作
    static func R(reverse: Bool = false) -> Self {
        // 选择需要从 x 轴正向看过去
        .init(
            pieceIndex: x2,
            pieceNextIndex: nextIndex(reverse),
            around: SCNVector3(reverse ? 1 : -1, 0, 0)
        )
    }

    // r 操作
    static func r(reverse: Bool = false) -> Self {
        // 选择需要从 x 轴正向看过去
        .init(
            pieceIndex: x1 + x2,
            pieceNextIndex: layer2NextIndex(reverse),
            around: SCNVector3(reverse ? 1 : -1, 0, 0)
        )
    }

    // L 操作
    static func L(reverse: Bool = false) -> Self {
        return .init(
            pieceIndex: x0_,
            pieceNextIndex: nextIndex(reverse),
            around: SCNVector3(reverse ? -1 : 1, 0, 0)
        )
    }

    // l 操作
    static func l(reverse: Bool = false) -> Self {
        return .init(
            // 选择需要从 x 轴反向看过去
            pieceIndex: x0_ + x1_,
            pieceNextIndex: layer2NextIndex(reverse),
            // 要从 x 轴 负轴看, l 才能正旋
            around: SCNVector3(reverse ? -1 : 1, 0, 0)
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

    // M 操作
    static func M(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: x1_,
            pieceNextIndex: nextIndex(reverse),
            around: SCNVector3(reverse ? -1 : 1, 0, 0)
        )
    }

    // E 操作
    static func E(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: [
                (0, 1, 0), (1, 1, 0), (2, 1, 0),
                (0, 1, 1), (1, 1, 1), (2, 1, 1),
                (0, 1, 2), (1, 1, 2), (2, 1, 2)
            ],
            clockwise: clockwise,
            around: SCNVector3(0, clockwise ? 1 : -1, 0)
        )
    }

    // S 操作
    static func S(clockwise: Bool = true) -> Self {
        .init(
            pieceIndex: [
                (0, 2, 1), (1, 2, 1), (2, 2, 1),
                (0, 1, 1), (1, 1, 1), (2, 1, 1),
                (0, 0, 1), (1, 0, 1), (2, 0, 1)
            ],
            clockwise: clockwise,
            around: SCNVector3(0, 0, clockwise ? -1 : 1)
        )
    }

    /// x 操作
    static func x(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: x0 + x1 + x2,
            pieceNextIndex: layer3NextIndex(reverse),
            around: SCNVector3(reverse ? 1 : -1, 0, 0)
        )
    }
}
