//
//  CubeStateThumbnail.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/27.
//

import SwiftUI

#if os(macOS)
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
#endif

#if os(iOS)
struct CubeStateThumbnail: View {
    let index: CubeStateIndex

    var body: some View {
        VStack {
            GeometryReader { proxy in
                if let image = UIImage(named: index.imagename) {
                    Image(uiImage: image)
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
#endif

#Preview {
    CubeStateThumbnail(index: .init(type: .f2l, index: 0))
        .frame(width: 36)
}
