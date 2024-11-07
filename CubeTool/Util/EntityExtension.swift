//
//  EntityExtension.swift
//  CubeTool
//
//  Created by Wttch on 2024/11/5.
//

import Foundation
import SwiftUI

extension CubeStateIndex {
    var thumbnailImage: Image {
        if let image = Image(named: self.imagename) {
            image
        } else {
            Image(systemName: "photo.badge.exclamationmark.fill")
        }
    }
}
