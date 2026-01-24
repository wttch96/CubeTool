//
//  CubeRotateComponent.swift
//  CubeTool
//
//  Created by Wttch on 2026/1/23.
//

import Foundation
import RealityKit

struct CubeRotateComponent: Component {
    var isOperating: Bool = false
    var operators: [CubeMove] = []
    var immediate: Bool = false
}
