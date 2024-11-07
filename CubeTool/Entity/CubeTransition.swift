//
//  CubeTransition.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/27.
//

import Foundation

/// 公式的定义
struct CubeFormula: Decodable, Equatable, Hashable {
    /// 公式到达的状态
    let reach: Int
    /// 公式的 key
    let key: String?
    /// 公式的前缀
    let prefix: String?
    /// 公式的附加值
    let suffix: String?
    /// 公式的字符串
    let formula: String?

    let comment: String?

    init(from decoder: any Decoder) throws {
        var append: String? = nil
        var prefix: String? = nil
        var formula: String? = nil
        var key: String? = nil
        var reach = 0
        var comment: String? = nil
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            reach = try container.decodeIfPresent(Int.self, forKey: .reach) ?? 0
            // 尝试 formula
            try formula = container.decodeIfPresent(String.self, forKey: .formula)
            // 结束
            if formula == nil {
                key = try container.decodeIfPresent(String.self, forKey: .key)
                prefix = try container.decodeIfPresent(String.self, forKey: .prefix)
                append = try container.decodeIfPresent(String.self, forKey: .suffix)
            }
            comment = try container.decodeIfPresent(String.self, forKey: .comment)
        } catch {
            let container = try decoder.singleValueContainer()
            key = try container.decode(String.self)
            append = nil
            prefix = nil
        }
        self.key = key
        self.suffix = append
        self.prefix = prefix
        self.formula = formula
        self.reach = reach
        self.comment = comment
    }

    enum CodingKeys: CodingKey {
        case reach

        case key
        case prefix
        case suffix

        case formula

        case comment
    }
}

struct CubeTransition: Decodable {
    let formula: [String: String]
    let transition: [String: [CubeFormula]]

    init() {
        self.formula = [:]
        self.transition = [:]
    }
}

extension CubeTransition {
    /// 获取公式的字符串
    func formula(_ cubeFormula: CubeFormula) -> String {
        if let formula = cubeFormula.formula {
            return formula
        }
        if let key = cubeFormula.key {
            return formula[key] ?? ""
        }

        return ""
    }

    func completeFormula(_ formula: CubeFormula?) -> String {
        guard let formula = formula else { return "" }
        let result = self.formula(formula)

        return (formula.prefix ?? "") + result + (formula.suffix ?? "")
    }
}

extension CubeTransition {
    static func from(systemName: String) -> CubeTransition {
        guard let url = Bundle.main.url(forResource: systemName, withExtension: "json") else {
            return CubeTransition()
        }
        return from(contentsOf: url)
    }

    static func from(contentsOf url: URL) -> CubeTransition {
        guard let data = try? Data(contentsOf: url) else { return CubeTransition() }
        guard let transitions = try? JSONDecoder().decode(CubeTransition.self, from: data) else { return CubeTransition() }
        return transitions
    }
    

    /// 获取哪个状态通过 formulaKey 公式可以转变为 state 状态
    func origin(_ formulaKey: CubeFormula, _ state: String) -> String? {
//        for (from, toTransition) in transition {
//            for (to, key) in toTransition {
//                if formulaKey == key, to == state {
//                    return from
//                }
//            }
//        }
        return nil
    }

    /// 获取哪个状态通过 formulaKey 公式可以转变为 currentState 状态
    func statesLeadingTo(currentState: Int) -> [String: CubeFormula] {
        var result: [String: CubeFormula] = [:]
        
        for (from, toTransitions) in transition {
            for transition in toTransitions {
                if transition.reach == currentState {
                    result[from] = transition
                }
            }
        }
        
        return result
    }
}
