//
//  ResourceUtil.swift
//  CubeTool
//
//  Created by Wttch on 2024/11/4.
//

struct ResourceUtil {
    private init() {}

    public static let shared = ResourceUtil()

    /// F2L 状态转换
    private let f2lTransitions = CubeTransition.from(systemName: "F2L-transition")
    /// OLL 状态转换
    private let ollTransitions = CubeTransition.from(systemName: "OLL-transition")

    /// 公式列表
    private let stateSections = StateSection.load(systemName: "StateList")

    /// 状态 index 字符串, %02d 形式
    fileprivate func stateIndex(of index: CubeStateIndex) -> String {
        String(format: "%02d", index.index)
    }

    /// 状态缩略图
    fileprivate func stateThumbnail(of index: CubeStateIndex) -> String {
        "\(index.type.rawValue)/\(stateIndex(of: index))"
    }

    /// 状态 json 文件
    fileprivate func stateFile(of index: CubeStateIndex) -> String {
        "\(index.type.rawValue)-\(stateIndex(of: index))"
    }

    func transitions(of type: CubeStateType) -> CubeTransition {
        switch type {
        case .f2l: return f2lTransitions
        case .oll: return ollTransitions
        case .pll: return CubeTransition()
        }
    }

    func stateLeadingTo(_ index: CubeStateIndex) -> [String: CubeFormula] {
        return transitions(of: index.type).statesLeadingTo(currentState: index.index)
    }
    
    func reachableStates(_ index: CubeStateIndex) -> [CubeFormula] {
        return transitions(of: index.type).transition[index.indexString] ?? []
    }

    func solve(_ index: CubeStateIndex) -> CubeFormula? {
        let transitions = self.transitions(of: index.type).transition
        return transitions[index.indexString]?.first { $0.reach == 0 }
    }
}

extension CubeStateIndex {
    var indexString: String {
        ResourceUtil.shared.stateIndex(of: self)
    }

    var imagename: String {
        ResourceUtil.shared.stateThumbnail(of: self)
    }

    var filename: String {
        ResourceUtil.shared.stateFile(of: self)
    }
}
