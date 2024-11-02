//
//  CubeTransition.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/27.
//

import Foundation

/// 公式的定义
struct CubeFormula: Decodable, Equatable {
    /// 公式的类型
    let type: FormulaType
    /// 公式的值,  `type` 是 key, 则是公式的key的值
    /// `type` 是 origin, 则是公式的原始值
    let value: String
    /// 公式的前缀
    let prefix: String?
    /// 公式的附加值
    let suffix: String?

    let formula: String?

    enum CodingKeys: CodingKey {
        case type
        case value
        case formula
        case prefix
        case suffix
    }

    init(from decoder: any Decoder) throws {
        var type: FormulaType = .key
        var value = ""
        var append: String? = nil
        var prefix: String? = nil
        var formula: String? = nil
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            // 尝试 formula
            try formula = container.decodeIfPresent(String.self, forKey: .formula)
            // 结束
            if formula == nil {
                type = try container.decode(FormulaType.self, forKey: .type)
                value = try container.decode(String.self, forKey: .value)
                prefix = try container.decodeIfPresent(String.self, forKey: .prefix)
                append = try container.decodeIfPresent(String.self, forKey: .suffix)
            } else {
                print("A")
            }
        } catch {
            let container = try decoder.singleValueContainer()
            type = .key
            value = try container.decode(String.self)
            append = nil
            prefix = nil
        }
        self.type = type
        self.value = value
        self.suffix = append
        self.prefix = prefix
        self.formula = formula
    }

    enum FormulaType: String, Decodable {
        case key
        case origin
    }
}

struct CubeTransition: Decodable {
    let formula: [String: String]

    let formulaPair: [String: String]

    let transition: [String: [String: CubeFormula]]

    init() {
        self.formula = [:]
        self.transition = [:]
        self.formulaPair = [:]
    }
}

extension CubeTransition {
    /// 获取公式的字符串
    func formula(_ cubeFormula: CubeFormula) -> String {
        if let formula = cubeFormula.formula {
            return formula
        }
        switch cubeFormula.type {
        case .key:
            return formula[cubeFormula.value] ?? ""
        case .origin:
            return cubeFormula.value
        }
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
        for (from, toTransition) in transition {
            for (to, key) in toTransition {
                if formulaKey == key, to == state {
                    return from
                }
            }
        }
        return nil
    }

    /// 获取哪个状态通过 formulaKey 公式可以转变为 currentState 状态
    func statesLeadingTo(currentState: String) -> [String: CubeFormula] {
        var result: [String: CubeFormula] = [:]

        for (from, toTransition) in transition {
            for (to, key) in toTransition {
                if to == currentState {
                    result[from] = key
                }
            }
        }

        return result
    }

    func reachableStates(from state: String) -> [String: CubeFormula] {
        return [:]
    }
}
