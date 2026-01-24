//
//  Formula.swift
//  CubeTool
//
//  Created by Wttch's Mac mini on 2026/1/24.
//

import Foundation



struct Transition: Codable {
    let from: CubeStateIndex
    let to: CubeStateIndex
    let formula: String
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let from = try container.decode(String.self, forKey: .from)
        let to = try container.decode(String.self, forKey: .to)
        self.formula = try container.decode(String.self, forKey: .formula)
        self.from = CubeStateIndex(from)!
        self.to = CubeStateIndex(to)!
    }
}


struct Formula: Codable {
    let simple: [String: String]
    let formula: [Transition]
}
