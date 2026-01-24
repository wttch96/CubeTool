//
//  CubeInitComponent.swift
//  CubeTool
//
//  Created by Wttch's Mac mini on 2026/1/24.
//

import RealityKit

/// 魔方初始化
struct CubeInitComponent: Component {
    /// 魔方状态
    var state: CubeStateType = .f2l
    /// 从初始化状态重放的公式，为了到达某个公式起点状态
    var formula: String? = nil
    /// 魔方是否初始化完成
    var inited: Bool = false
    /// 是否已经染色
    var colored: Bool = false
}
