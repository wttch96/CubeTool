//
//  StateSection.swift
//  CubeTool
//
//  Created by Wttch on 2024/11/4.
//
import Foundation

struct StateSection: Decodable {
    let title: String
    let state: [Int]
}

extension StateSection {
    static func load(constantsOf: URL) -> [CubeStateType: [StateSection]] {
        guard let data = try? Data(contentsOf: constantsOf),
              let jsonDictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return [:] }

        var result: [CubeStateType: [StateSection]] = [:]
        
        jsonDictionary.forEach { key, value in
            guard let type = CubeStateType(rawValue: key),
                  let items = value as? [[String: Any]] else { return }

            result[type] = items.compactMap { item in
                guard let title = item["title"] as? String,
                      let state = item["state"] as? [Int] else { return nil }
                return StateSection(title: title, state: state)
            }
        }

        return result
    }

    static func load(systemName: String) -> [CubeStateType: [StateSection]] {
        let url = Bundle.main.url(forResource: systemName, withExtension: "json")!
        return load(constantsOf: url)
    }
}
