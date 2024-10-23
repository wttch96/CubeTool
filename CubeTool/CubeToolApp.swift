//
//  CubeToolApp.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/21.
//

import SwiftUI
import SwiftData

@main
struct CubeToolApp: App {
    var body: some Scene {
        WindowGroup {
            CubeView()
                .onAppear {
                    
                    // 现在支持解析带括号的公式
                    let formula = "M'(R'U'RU')(R'U2RU')2M"
                    let parsedMoves = CubeParser.parseMoves(from: formula)
                    CubeParser.executeMoves(parsedMoves)
                }
        }
    }
}
