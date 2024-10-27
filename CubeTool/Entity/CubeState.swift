//
//  CubeState.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/28.
//

import Foundation

enum CubeStateType: String {
    case f2l = "F2L"
    case oll = "OLL"
}
//
//extension CubeStateType {
//    var pieces: [Pieces] {
//        switch self {
//        case .f2l:
//            return Pieces.y2Gray
//        case .oll:
//            return Pieces.topWhite
//        }
//    }
//}

struct CubeStateIndex: Equatable {
    let type: CubeStateType
    let index: Int

    init(type: CubeStateType, index: Int) {
        self.type = type
        self.index = index
    }

    var indexString: String {
        String(format: "%02d", index)
    }

    var filename: String {
        "\(type.rawValue)-\(String(format: "%02d", index))"
    }

    var imagename: String {
        "\(type.rawValue)/\(String(format: "%02d", index))"
    }

    static func f2l(_ index: Int) -> CubeStateIndex {
        CubeStateIndex(type: .f2l, index: index)
    }
    static func oll(_ index: Int) -> CubeStateIndex {
        CubeStateIndex(type: .oll, index: index)
    }
}
