//
//  PieceDefinition.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/22.
//

struct PieceDefinition {
    let stickers: [StickerDefinition?]

    private init(_ stickers: [StickerDefinition?]) {
        self.stickers = stickers
    }

    static let all: [Self] = [
        // L
        .init([nil, .init(.orange), .init(.green), nil, nil, .init(.yellow)]),
        .init([nil, nil, .init(.green).top(), nil, nil, .init(.yellow).right()]),
        .init([.init(.red), nil, .init(.green), nil, nil, .init(.yellow)]),
        .init([nil, .init(.orange).left(), .init(.green).right(), nil, nil, nil]),
        .init([nil, nil, .init(.green).top().bottom(), nil, nil, nil]),
        .init([.init(.red).right(), nil, .init(.green).left(), nil, nil, nil]),
        .init([nil, .init(.orange), .init(.green), nil, .init(.white), nil]),
        .init([nil, nil, .init(.green).bottom(), nil, .init(.white).right(), nil]),
        .init([.init(.red), nil, .init(.green), nil, .init(.white), nil]),
        // M
        .init([nil, .init(.orange).bottom(), nil, nil, nil, .init(.yellow).bottom()]),
        .init([nil, nil, nil, nil, nil, .init(.yellow).top().bottom()]),
        .init([.init(.red).top(), nil, nil, nil, nil, .init(.yellow).top()]),
        .init([nil, .init(.orange).top().bottom(), nil, nil, nil, nil]),
        .init([nil, nil, nil, nil, nil, nil]),
        .init([.init(.red).top().bottom(), nil, nil, nil, nil, nil]),
        .init([nil, .init(.orange).top(), nil, nil, .init(.white).top(), nil]),
        .init([nil, nil, nil, nil, .init(.white).top().bottom(), nil]),
        .init([.init(.red).bottom(), nil, nil, nil, .init(.white).bottom(), nil]),
        // R
        .init([nil, .init(.orange), nil, .init(.blue), nil, .init(.yellow)]),
        .init([nil, nil, nil, .init(.blue).top(), nil, .init(.yellow).left()]),
        .init([.init(.red), nil, nil, .init(.blue), nil, .init(.yellow)]),
        .init([nil, .init(.orange).right(), nil, .init(.blue).left(), nil, nil]),
        .init([nil, nil, nil, .init(.blue).top().bottom(), nil, nil]),
        .init([.init(.red).left(), nil, nil, .init(.blue).right(), nil, nil]),
        .init([nil, .init(.orange), nil, .init(.blue), .init(.white), nil]),
        .init([nil, nil, nil, .init(.blue).bottom(), .init(.white).left(), nil]),
        .init([.init(.red), nil, nil, .init(.blue), .init(.white), nil]),
    ]
}
