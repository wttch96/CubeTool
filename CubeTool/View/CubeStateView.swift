//
//  CubeStateView.swift
//  CubeTool
//
//  Created by Wttch on 2024/11/4.
//

import SwiftUI

/// 魔方状态详情
struct CubeStateView: View {
    static let cubeView = CubeView()
    let index: CubeStateIndex

    /// 
    private let transitions: CubeTransition
    /// 从哪里来
    private let statesLeadingTo: [String: CubeFormula]
    /// 可以到哪里去
    private let reachableStates: [CubeFormula]

    @State private var showSettingSheet = false
    @AppStorage("op-duration") private var duration: Double = 0.2

    init(index: CubeStateIndex) {
        self.index = index

        transitions = ResourceUtil.shared.transitions(of: index.type)
        statesLeadingTo = ResourceUtil.shared.stateLeadingTo(index)
        // 只保留复原
        reachableStates = ResourceUtil.shared.reachableStates(index)
            .filter { $0.reach == 0 }

        cubeView.performCube(index.filename)
    }

    var body: some View {
        VStack {
            cubeView
                .frame(width: 300, height: 300)

            Divider()

            HStack {
                VStack {
                    Text("从这里来")
                        .font(.headline)
                    formulaListView(statesLeadingTo)
                }
                Divider()
                VStack {
                    Text("可以到哪里去")
                        .font(.headline)
                    formulaListView(reachableStates)
                }
            }
        }
        .navigationTitle(index.filename)
        .toolbar(content: {
            Button {
                showSettingSheet.toggle()
            } label: {
                Image(systemName: "gear")
            }
        })
        .sheet(isPresented: $showSettingSheet, content: {
            Form {
                Text("动画用时: \(duration * 1000, specifier: "%.0f") ms")
                Slider(value: $duration, in: 0.1 ... 1, step: 0.02, label: {
                    Text("")
                }, minimumValueLabel: {
                    Text("100")
                }, maximumValueLabel: {
                    Text("1000 ms")
                })

                HStack {
                    Spacer()
                    Button("完成", action: {
                        showSettingSheet.toggle()
                    })
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        })
    }

    var cubeView = Self.cubeView
}

extension CubeStateView {
    @ViewBuilder
    private func formulaListView(_ formulaMap: [String: CubeFormula]) -> some View {
        List {
            ForEach(formulaMap.keys.sorted(), id: \.self) { state in
                if let leadingTo = formulaMap[state] {
                    let stateIndex = index.update(newIndex: Int(state) ?? 0)
                    formulaView(leadingTo, thumbnailIndex: stateIndex, stateIndex: stateIndex)
                }
            }
        }
    }

    @ViewBuilder
    private func formulaListView(_ formulas: [CubeFormula]) -> some View {
        List {
            ForEach(formulas, id: \.self) { formula in
                let thumbnailIndex = index.update(newIndex: formula.reach)
                formulaView(formula, thumbnailIndex: thumbnailIndex, stateIndex: index)
            }
        }
    }

    @ViewBuilder
    private func formulaView(_ formula: CubeFormula, thumbnailIndex: CubeStateIndex, stateIndex: CubeStateIndex) -> some View {
        HStack {
            thumbnailIndex.thumbnailImage
                .resizable()
                .frame(width: 36, height: 36)
            VStack(alignment: .leading) {
                if let key = formula.key {
                    Text(key)
                        .font(.footnote)
                }
                Text(transitions.completeFormula(formula))
                    .bold()
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            cubeView.performCube(stateIndex.filename)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                cubeView.exec(self.transitions.completeFormula(formula), duration: duration)
            }
        }
    }
}

#Preview {
    CubeStateView(index: .f2l(10))
        .navigationTitle("Preview")
        .frame(height: 600)
}
