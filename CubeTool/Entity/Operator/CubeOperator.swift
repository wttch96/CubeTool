//
//  CubeOperator.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/22.
//

import Foundation
import SceneKit

/// 魔方操作
struct CubeOperator {
    /// 旋转的块的索引
    var pieceIndex: [(x: Int, y: Int, z: Int)]
    /// 旋转后的块的索引
    var pieceNextIndex: [Int]
    /// 旋转的方向
    var around: IntVector3

    /// 初始化
    init(pieceIndex: [(x: Int, y: Int, z: Int)], pieceNextIndex: [Int], around: IntVector3) {
        self.pieceIndex = pieceIndex
        self.pieceNextIndex = pieceNextIndex
        self.around = around
    }

    /// 将层的索引顺序反向
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
    private static let x1: [(x: Int, y: Int, z: Int)] = x0.map { (x: $0.x + 1, y: $0.y, z: $0.z) }
    private static let x2: [(x: Int, y: Int, z: Int)] = x0.map { (x: $0.x + 2, y: $0.y, z: $0.z) }
    private static let x0_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: x0)
    private static let x1_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: x1)
    private static let x2_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: x2)

    private static let y0: [(x: Int, y: Int, z: Int)] = [
        (0, 0, 0), (1, 0, 0), (2, 0, 0),
        (0, 0, 1), (1, 0, 1), (2, 0, 1),
        (0, 0, 2), (1, 0, 2), (2, 0, 2)
    ]
    private static let y1: [(x: Int, y: Int, z: Int)] = y0.map { (x: $0.x, y: $0.y + 1, z: $0.z) }
    private static let y2: [(x: Int, y: Int, z: Int)] = y0.map { (x: $0.x, y: $0.y + 2, z: $0.z) }
    private static let y0_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: y0)
    private static let y1_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: y1)
    private static let y2_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: y2)

    private static let z0: [(x: Int, y: Int, z: Int)] = [
        (0, 2, 0), (1, 2, 0), (2, 2, 0),
        (0, 1, 0), (1, 1, 0), (2, 1, 0),
        (0, 0, 0), (1, 0, 0), (2, 0, 0)
    ]
    private static let z1: [(x: Int, y: Int, z: Int)] = z0.map { (x: $0.x, y: $0.y, z: $0.z + 1) }
    private static let z2: [(x: Int, y: Int, z: Int)] = z0.map { (x: $0.x, y: $0.y, z: $0.z + 2) }
    private static let z0_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: z0)
    private static let z1_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: z1)
    private static let z2_: [(x: Int, y: Int, z: Int)] = reverseLayer(layer: z2)

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

    // MARK: F, B, S, z

    static func F(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: z2,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(0, 0, reverse ? 1 : -1)
        )
    }

    static func f(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: z1 + z2,
            pieceNextIndex: layer2NextIndex(reverse),
            around: IntVector3(0, 0, reverse ? 1 : -1)
        )
    }

    static func B(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: z0_,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(0, 0, reverse ? -1 : 1)
        )
    }

    static func b(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: z0_ + z1_,
            pieceNextIndex: layer2NextIndex(reverse),
            around: IntVector3(0, 0, reverse ? -1 : 1)
        )
    }

    static func S(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: z1,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(0, 0, reverse ? 1 : -1)
        )
    }

    static func z(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: z0 + z1 + z2,
            pieceNextIndex: layer3NextIndex(reverse),
            around: IntVector3(0, 0, reverse ? 1 : -1)
        )
    }

    // MARK: L, R, M, x

    static func L(reverse: Bool = false) -> Self {
        return .init(
            pieceIndex: x0_,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(reverse ? -1 : 1, 0, 0)
        )
    }

    static func l(reverse: Bool = false) -> Self {
        return .init(
            // 选择需要从 x 轴反向看过去
            pieceIndex: x0_ + x1_,
            pieceNextIndex: layer2NextIndex(reverse),
            // 要从 x 轴 负轴看, l 才能正旋
            around: IntVector3(reverse ? -1 : 1, 0, 0)
        )
    }

    static func R(reverse: Bool = false) -> Self {
        // 选择需要从 x 轴正向看过去
        .init(
            pieceIndex: x2,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(reverse ? 1 : -1, 0, 0)
        )
    }

    static func r(reverse: Bool = false) -> Self {
        // 选择需要从 x 轴正向看过去
        .init(
            pieceIndex: x1 + x2,
            pieceNextIndex: layer2NextIndex(reverse),
            around: IntVector3(reverse ? 1 : -1, 0, 0)
        )
    }

    static func M(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: x1_,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(reverse ? -1 : 1, 0, 0)
        )
    }

    static func x(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: x0 + x1 + x2,
            pieceNextIndex: layer3NextIndex(reverse),
            around: IntVector3(reverse ? 1 : -1, 0, 0)
        )
    }

    // MARK: U, D, E, y

    static func U(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: y2,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(0, reverse ? 1 : -1, 0)
        )
    }

    static func u(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: y1 + y2,
            pieceNextIndex: layer2NextIndex(reverse),
            around: IntVector3(0, reverse ? 1 : -1, 0)
        )
    }

    static func D(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: y0_,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(0, reverse ? -1 : 1, 0)
        )
    }

    static func d(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: y0_ + y1_,
            pieceNextIndex: layer2NextIndex(reverse),
            around: IntVector3(0, reverse ? -1 : 1, 0)
        )
    }
    
    static func E(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: y1_,
            pieceNextIndex: nextIndex(reverse),
            around: IntVector3(0, reverse ? -1 : 1, 0)
        )
    }
    
    static func y(reverse: Bool = false) -> Self {
        .init(
            pieceIndex: y0 + y1 + y2,
            pieceNextIndex: layer3NextIndex(reverse),
            around: IntVector3(0, reverse ? 1 : -1, 0)
        )
    }
}
