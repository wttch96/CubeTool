//
//  FormulaUtil.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/24.
//
import Cocoa
import SwiftLogMacro


@Log
class FormulaUtil {
    static let shared = FormulaUtil()
    
    let formula: Formula
    
    private init() {
        if let url = Bundle.main.url(forResource: "Formula", withExtension: "json") {
            let jsonData = try! Data(contentsOf: url)
            let decoder = JSONDecoder()
            formula = try! decoder.decode(Formula.self, from: jsonData)
            self.logger.info("Loaded formula with \(formula.formula.count) transitions.")
        } else {
            formula = Formula(simple: [:], formula: [])
        }
    }
    
    /// 查找初始化的公式
    func findInitFormula(to: CubeStateIndex) -> String? {
        return find(from: to.update(newIndex: 0), to: to)
    }
    
    
    func find(from: CubeStateIndex, to: CubeStateIndex) -> String? {
        return formula.formula.first { trans in
            trans.from == from && trans.to == to
        }?.formula
    }
}
