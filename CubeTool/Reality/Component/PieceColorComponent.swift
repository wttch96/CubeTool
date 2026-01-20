//
//  PieceColorComponent.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/20.
//

import Foundation
import RealityKit
import SwiftUI


struct PieceColorComponent: Component {
    var generaed: Bool = false
    
    let size: Float
    
    let left: Color?
    let right: Color?
    let up: Color?
    let down: Color?
    let front: Color?
    let back: Color?
    
    init(_ size: Float = 1.0, l: Color? = nil, r: Color? = nil,
         u: Color? = nil, d: Color? = nil,
         f: Color? = nil, b: Color? = nil) {
        self.size = size
        self.left = l
        self.right = r
        self.up = u
        self.down = d
        self.front = f
        self.back = b
    }
}
