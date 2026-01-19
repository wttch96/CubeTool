//
//  PieceDefinition.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/22.
//
import CoreGraphics

struct Pieces {
    let stickers: [StickerDefinition?]

    private init(_ stickers: [StickerDefinition?]) {
        self.stickers = stickers
    }

    static let f: CGColor = .init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0)
    static let b: CGColor = .init(red: 0.0, green: 1.0, blue: 0.5, alpha: 1.0)
    static let l: CGColor = .init(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
    static let r: CGColor = .init(red: 1.0, green: 0.0, blue: 0.5, alpha: 1.0)
    static let u: CGColor = .init(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
    static let d: CGColor = .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    private static let x0y1y2: [[CGColor?]] = [
        [nil, b, l, nil, nil, d],
        [nil, nil, l, nil, nil, d],
        [f, nil, l, nil, nil, d],
        [nil, b, l, nil, u, nil],
        [nil, nil, l, nil, u, nil],
        [f, nil, l, nil, u, nil],
    ]

    static let fs: StickerDefinition = .init(f)
    static let bs: StickerDefinition = .init(b)
    static let ls: StickerDefinition = .init(l)
    static let rs: StickerDefinition = .init(r)
    static let us: StickerDefinition = .init(u)
    static let ds: StickerDefinition = .init(d)
    static let gs: StickerDefinition = .init(.init(gray: 0.8, alpha: 1))

    private static let x0y12: [[StickerDefinition?]] = [
        [nil, bs, ls, nil, nil, ds],
        [nil, nil, ls.top(), nil, nil, ds.right()],
        [fs, nil, ls, nil, nil, ds],
        [nil, bs.left(), ls.right(), nil, nil, nil],
        [nil, nil, ls.center(), nil, nil, nil],
        [fs.right(), nil, ls.left(), nil, nil, nil],
    ]

    private static let x0y2: [[StickerDefinition?]] = [
        [nil, bs, ls, nil, us, nil],
        [nil, nil, ls.bottom(), nil, us.right(), nil],
        [fs, nil, ls, nil, us, nil],
    ]

    private static let x1y12: [[StickerDefinition?]] = [
        [nil, bs.bottom(), nil, nil, nil, ds.bottom()],
        [nil, nil, nil, nil, nil, ds.center()],
        [fs.top(), nil, nil, nil, nil, ds.top()],
        [nil, bs.center(), nil, nil, nil, nil],
        [nil, nil, nil, nil, nil, nil],
        [fs.center(), nil, nil, nil, nil, nil],
    ]

    private static let x1y2: [[StickerDefinition?]] = [
        [nil, bs.top(), nil, nil, us.top(), nil],
        [nil, nil, nil, nil, us.center(), nil],
        [fs.bottom(), nil, nil, nil, us.bottom(), nil],
    ]

    private static let x2y12: [[StickerDefinition?]] = [
        [nil, bs, nil, rs, nil, ds],
        [nil, nil, nil, rs.top(), nil, ds.left()],
        [fs, nil, nil, rs, nil, ds],
        [nil, bs.right(), nil, rs.left(), nil, nil],
        [nil, nil, nil, rs.center(), nil, nil],
        [fs.left(), nil, nil, rs.right(), nil, nil],
    ]

    private static let x2y2: [[StickerDefinition?]] = [
        [nil, bs, nil, rs, us, nil],
        [nil, nil, nil, rs.bottom(), us.left(), nil],
        [fs, nil, nil, rs, us, nil],
    ]

    private static let x0y2TopWhite: [[StickerDefinition?]] = [
        [nil, gs, gs, nil, us, nil],
        [nil, nil, gs.bottom(), nil, us.right(), nil],
        [gs, nil, gs, nil, us, nil],
    ]
    private static let x1y2TopWhite: [[StickerDefinition?]] = [
        [nil, gs.top(), nil, nil, us.top(), nil],
        [nil, nil, nil, nil, us.center(), nil],
        [gs.bottom(), nil, nil, nil, us.bottom(), nil],
    ]

    private static let x2y2TopWhite: [[StickerDefinition?]] = [
        [nil, gs, nil, gs, us, nil],
        [nil, nil, nil, gs.bottom(), us.left(), nil],
        [gs, nil, nil, gs, us, nil],
    ]

    private static let x0y2Gray = [
        [nil, gs, gs, nil, gs, nil],
        [nil, nil, gs.bottom(), nil, gs.right(), nil],
        [gs, nil, gs, nil, gs, nil],
    ]

    private static let x1y2Gray = [
        [nil, gs.top(), nil, nil, gs.top(), nil],
        [nil, nil, nil, nil, gs.center(), nil],
        [gs.bottom(), nil, nil, nil, gs.bottom(), nil],
    ]

    private static let x2y2Gray = [
        [nil, gs, nil, gs, gs, nil],
        [nil, nil, nil, gs.bottom(), gs.left(), nil],
        [gs, nil, nil, gs, gs, nil],
    ]

    static let all: [Self] = (
        x0y12 + x0y2 + x1y12 + x1y2 + x2y12 + x2y2
    ).map(Self.init)

    static let topWhite: [Self] = (
        x0y12 + x0y2TopWhite + x1y12 + x1y2TopWhite + x2y12 + x2y2TopWhite
    ).map(Self.init)

    static let y2Gray: [Self] = (
        x0y12 + x0y2Gray + x1y12 + x1y2Gray + x2y12 + x2y2Gray
    ).map(Self.init)
}

extension CubeStateType {
    var pieces: [Pieces] {
        switch self {
        case .pll:
            Pieces.all
        case .f2l:
            Pieces.y2Gray
        case .oll:
            Pieces.topWhite
        }
    }
}
