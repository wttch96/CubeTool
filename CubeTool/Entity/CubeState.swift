//
//  CubeState.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/28.
//

import Foundation

enum CubeStateType: String, Codable, CaseIterable, Hashable, Identifiable {
    case f2l = "F2L"
    case oll = "OLL"
    case pll = "PLL"
    
    var id: String { self.rawValue }
}

struct CubeStateIndex: Codable, Equatable, Hashable, CustomStringConvertible {
    let type: CubeStateType
    let index: Int
    
    init(type: CubeStateType, index: Int) {
        self.type = type
        self.index = index
    }
    
    init?(_ rawValue: String) {
        let indexs = rawValue.split(separator: "-").compactMap { String($0) }
        if let type = CubeStateType(rawValue: indexs[0]),
           let index = Int(indexs[1])
        {
            self.type = type
            self.index = index
        } else {
            return nil
        }
    }
    
    /// 更新索引
    func update(newIndex index: Int) -> Self {
        return CubeStateIndex(type: self.type, index: index)
    }
    
    static func f2l(_ index: Int) -> CubeStateIndex {
        CubeStateIndex(type: .f2l, index: index)
    }
    
    static func oll(_ index: Int) -> CubeStateIndex {
        CubeStateIndex(type: .oll, index: index)
    }
    
    var description: String {
        return "\(self.type.rawValue)-\(self.index)"
    }
}
