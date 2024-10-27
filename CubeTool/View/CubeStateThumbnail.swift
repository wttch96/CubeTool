//
//  CubeStateThumbnail.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/27.
//

import SwiftUI

struct CubeStateThumbnail: View {
    let index: CubeStateIndex

    var body: some View {
        VStack {
            GeometryReader { proxy in
                if let image = NSImage(named: index.imagename) {
                    Image(nsImage: image)
                        .resizable()
                        .frame(width: proxy.size.width, height: proxy.size.width)
                        .padding(2)
                        .background(index.type == .f2l ? .clear : .white)
                }
            }
            Spacer()
            Text(index.indexString)
        }
    }
}

#Preview {
    CubeStateThumbnail(index: .f2l(0))
        .frame(width: 36)
}
