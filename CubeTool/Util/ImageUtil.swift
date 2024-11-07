//
//  ImageUtil.swift
//  CubeTool
//
//  Created by Wttch on 2024/11/4.
//
import SwiftUI

extension Image {
    init?(named: String) {
        #if os(macOS)
        if let image = NSImage(named: named) {
            self.init(nsImage: image)
        } else {
            return nil
        }
        #endif
        #if os(iOS)
        if let image = UIImage(named: named) {
            self.init(uiImage: image)
        } else {
            return nil
        }
        #endif
    }
}

