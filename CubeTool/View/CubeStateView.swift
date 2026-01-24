//
//  CubeStateView.swift
//  CubeTool
//
//  Created by Wttch on 2024/11/4.
//

import RealityKit
import SwiftLogMacro
import SwiftUI

/// 魔方状态详情
@Log
struct CubeStateView: View {
    let index: CubeStateIndex

    /// 
    private let transitions: CubeTransition
    /// 从哪里来
    private let statesLeadingTo: [String: CubeFormula]
    /// 可以到哪里去
    private let reachableStates: [CubeFormula]

    /// 复原公式
    @State private var resetFormula: String? = nil

    @State private var showSettingSheet = false
    @AppStorage("op-duration") private var duration: Double = 0.2

    @State private var cubeEntity = Entity()
    private let camera = PerspectiveCamera()

    init(index: CubeStateIndex) {
        self.index = index

        transitions = ResourceUtil.shared.transitions(of: index.type)
        statesLeadingTo = ResourceUtil.shared.stateLeadingTo(index)
        // 只保留复原
        reachableStates = ResourceUtil.shared.reachableStates(index)
            .filter { $0.reach == 0 }
    }

    var body: some View {
        VStack {
            RealityView { content in
                cubeEntity.components[CubeInitComponent.self] = CubeInitComponent()
                cubeEntity.components[CubeRotateComponent.self] = CubeRotateComponent(isOperating: false)
                cubeEntity.name = "CubeRoot"
                content.add(cubeEntity)

                addDebugAxes(to: content)

                let cameraPosition: SIMD3<Float> = [4, 4, 4] // 稍微拉远一点，防止贴脸
                let targetPosition: SIMD3<Float> = [0, 0, 0]
                camera.look(at: targetPosition, from: cameraPosition, relativeTo: nil)
                content.add(camera)
            }

            HStack {
                Text("复原公式: \(self.resetFormula ?? "无")")
                    .font(.title)
                    .padding(4)
                Spacer()

                Button("复原") {
                    if let resetFormula {
                        let formula = FormulaUtil.shared.findInitFormula(to: index)
                        cubeEntity.components.remove(CubeRotateComponent.self)
                        cubeEntity.components.set(CubeInitComponent(
                            formula: formula
                        ))
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                            
                            cubeEntity.components.set(CubeRotateComponent(
                                operators: CubeParser.parseMoves(from: resetFormula)
                            ))
                        })
                    }
                }
            }

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
        .onAppear {
            let formula = FormulaUtil.shared.findInitFormula(to: index)
            self.logger.info("\(index)初始化公式: \(formula ?? "无")")
            cubeEntity.components.set(CubeInitComponent(
                formula: formula,
                inited: false,
                colored: false
            ))
        }
        .onChange(of: index) { _, newValue in
            let formula = FormulaUtil.shared.findInitFormula(to: newValue)
            self.resetFormula = FormulaUtil.shared.find(from: newValue, to: newValue.update(newIndex: 0))
            self.logger.info("\(newValue)初始化公式: \(formula ?? "无")")
            cubeEntity.components.set(CubeInitComponent(
                formula: formula,
                inited: false,
                colored: false
            ))
        }
        .onTapGesture {
            cubeEntity.components.set(CubeRotateComponent(operators: [.x]))
        }
    }
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
    }
}

extension CubeStateView {
    // 辅助函数：添加坐标轴
    private func addDebugAxes(to parent: RealityViewCameraContent) {
        let axisLength: Float = 3
        let thickness: Float = 0.05

        func createAxis(size: SIMD3<Float>, color: NSColor, pos: SIMD3<Float>) -> ModelEntity {
            let mesh = MeshResource.generateBox(size: size)
            let material = SimpleMaterial(color: color, isMetallic: false)
            let entity = ModelEntity(mesh: mesh, materials: [material])
            entity.position = pos
            return entity
        }

        parent.add(createAxis(size: [axisLength, thickness, thickness], color: .red, pos: [axisLength/2, 0, 0])) // X
        parent.add(createAxis(size: [thickness, axisLength, thickness], color: .green, pos: [0, axisLength/2, 0])) // Y
        parent.add(createAxis(size: [thickness, thickness, axisLength], color: .blue, pos: [0, 0, axisLength/2])) // Z
    }
}

#Preview {
    CubeStateView(index: .f2l(10))
        .navigationTitle("Preview")
        .frame(height: 600)
}
