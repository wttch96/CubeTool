//
//  PieceComponent.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/21.
//

import Foundation
import RealityKit

/// 
struct PieceComponent: Component {
    /// 索引 用来染色
    let index: SIMD3<Int>
    
    /// 位置
    var position: SIMD3<Int>
    
    var setuped: Bool = false
}

