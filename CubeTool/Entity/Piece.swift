//
//  Piece.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/24.
//

import Foundation
import SceneKit

// MARK: Piece

/// 魔方块定义
/// 从 x 轴正向向负向看去, 为 R 面
/// 从 y 轴正向向负向看去, 为 U 面
/// 从 z 轴正向向负向看去, 为 F 面
struct Piece: Codable {
    // 当前块的索引
    let index: IntVector3

    // 当前的旋转情况
    let rotate: IntVector4
    
    static let zero: Piece = Piece(index: .zero, rotate: .zero)
}

struct IntVector3: Codable {
    let x: Int
    let y: Int
    let z: Int
    
    static let zero = IntVector3(0, 0, 0)
    
}

struct IntVector4: Codable {
    let x: Int
    let y: Int
    let z: Int
    let w: Int
    
    static let zero: IntVector4 = IntVector4(0, 0, 0, 0)
}

extension IntVector4 {
    init(_ x: Int, _ y: Int, _ z: Int, _ w: Int) {
        self.init(x: x, y: y, z: z, w: w)
    }
    
    static func from(_ quaternion: SCNQuaternion) -> Self {
        return Self(Int(quaternion.x * 10000), Int(quaternion.y * 10000), Int(quaternion.z * 10000), Int(quaternion.w * 10000))
    }
    
    func toSCNQuaternion() -> SCNQuaternion {
        SCNQuaternion(Float(x) / 10000, Float(y) / 10000, Float(z) / 10000, Float(w) / 10000)
    }
}

extension IntVector3 {
    func toSIMD3() -> SIMD3<Int> {
        SIMD3<Int>(x, y, z)
    }
}

extension IntVector4 {
    func toSimdQuatf() -> simd_quatf {
        simd_quatf(ix: Float(x) / 10000, iy: Float(y) / 10000, iz: Float(z) / 10000, r: Float(w) / 10000)
    }
    
    static func from(_ quatf: simd_quatf) -> Self {
        return Self(Int(quatf.imag.x * 10000), Int(quatf.imag.y * 10000), Int(quatf.imag.z * 10000), Int(quatf.real * 10000))
    }
}

extension IntVector3 {
    init(_ x: Int, _ y: Int, _ z: Int) {
        self.init(x: x, y: y, z: z)
    }
    
    func toSCNVector3() -> SCNVector3 {
        SCNVector3(Float(x), Float(y), Float(z))
    }
    
}
