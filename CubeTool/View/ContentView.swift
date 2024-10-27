//
//  ContentView.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/24.
//

import SwiftLogMacro
import SwiftUI

@Log
struct ContentView: View {
    @State private var formula = ""
    @State private var title = ""
    @State private var selected: CubeStateIndex = .f2l(0)
    
    /// F2L 状态转换
    private let f2lTransitions = CubeTransition.from(systemName: "F2L-transition")
    /// OLL 状态转换
    private let ollTransitions = CubeTransition.from(systemName: "OLL-transition")
    
    private let cubeView = CubeView()
    
    @State private var curTransition: [String: CubeFormula] = [:]
    @State private var autoChangeState = false

    var body: some View {
        NavigationSplitView(sidebar: {
            List {
                Section("F2L") {
                    VStack {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 40)),
                            GridItem(.adaptive(minimum: 40)),
                            GridItem(.adaptive(minimum: 40)),
                            GridItem(.adaptive(minimum: 40))
                        ]) {
                            ForEach(0 ... 41, id: \.self) { i in
                                let index = CubeStateIndex.f2l(i)
                                CubeStateThumbnail(index: index)
                                    .frame(width: 36, height: 56)
                                    .onTapGesture {
                                        selected = .f2l(i)
                                        curTransition = transitions.transition[index.indexString] ?? [:]
                                    }
                            }
                        }
                        Spacer()
                    }
                }
                
                Section("OLL") {
                    VStack {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 40)),
                            GridItem(.adaptive(minimum: 40)),
                            GridItem(.adaptive(minimum: 40)),
                            GridItem(.adaptive(minimum: 40))
                        ]) {
                            ForEach(0 ... 57, id: \.self) { i in
                                let index = CubeStateIndex(type: .oll, index: i)
                                CubeStateThumbnail(index: index)
                                    .frame(width: 36, height: 56)
                                    .onTapGesture {
                                        selected = index
                                        curTransition = transitions.transition[index.indexString] ?? [:]
                                    }
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 240)
        }, detail: {
            HStack {
                VStack {
                    Toggle("完成后自动切换状态", isOn: $autoChangeState)
                    ForEach(curTransition.keys.sorted(), id: \.self) { key in
                        VStack(alignment: .leading) {
                            if let formulaKey = curTransition[key] {
                                let formula = transitions.formula(formulaKey)
                                HStack {
                                    if formulaKey.type == .key {
                                        Text(formulaKey.value)
                                            .font(.title3)
                                    }
                                    
                                    if let prefix = formulaKey.prefix {
                                        Text(prefix)
                                            .foregroundColor(.red)
                                    }
                                    Text(formula)
                                    if let suffix = formulaKey.suffix {
                                        Text(suffix)
                                            .foregroundColor(.blue)
                                    }
                                    Spacer()
                                }
                                .bold()
                                .font(.subheadline)
                                HStack {
                                    // 前一状态
                                    if formulaKey.value.starts(with: "F"),
                                       let origin = transitions.origin(formulaKey, selected.indexString),
                                       let originIndex = Int(origin)
                                    {
                                        let o:CubeStateIndex = selected.type == .f2l ? .f2l(originIndex) : .oll(originIndex)
                                        CubeStateThumbnail(index: o)
                                            .frame(width: 32, height: 48)
                                            .font(.subheadline)
                                        stepView(formulaKey: formulaKey.value)
                                    }
                                    
                                    CubeStateThumbnail(index: selected)
                                        .frame(width: 36, height: 54)
                                        .bold()
                                    
                                    stepView(formulaKey: formulaKey.value)
                                    
                                    let o:CubeStateIndex = selected.type == .f2l ? .f2l(Int(key) ?? 0) : .oll(Int(key) ?? 0)
                                    CubeStateThumbnail(index: o)
                                        .frame(width: 32, height: 48)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .onTapGesture {
                            // formula = curTransition[key]
                            cubeView.exec(transitions.completeFormula(curTransition[key])) {
                                if self.autoChangeState {
                                    let name = key
                                    logger.info("切换状态:\(name)")
                                    selected = .f2l(Int(name) ?? 0)
                                    curTransition = transitions.transition[name] ?? [:]
                                }
                            }
                        }
                    }
                    Spacer()
                }
                
                Spacer()
                VStack {
                    HStack {
                        Button("Reset", action: {
                            cubeView.performCube(Cube(stickerType: .y2Gray))
                        })
                        
                        Button("Print") {
                            cubeView.printCube()
                        }
                    }
                    cubeView
                        .frame(width: 300, height: 300)
                    
                    TextField("", text: $formula)
                        .onSubmit {
                            cubeView.exec(formula)
                        }
                    
                    Spacer()
                }
                .frame(width: 300)
            }
            .padding()
        })
        .navigationTitle(selected.indexString)
        .onChange(of: selected) { _, newValue in
            if let cube = Cube(systemName: newValue.filename) {
                cubeView.performCube(cube)
            }
        }
    }
}

extension ContentView {
    @ViewBuilder
    func stepView(formulaKey: String) -> some View {
        VStack {
            Text(formulaKey)
                .font(.footnote)
            Image(systemName: "arrowshape.right")
        }
        .offset(y: -12)
    }
    
    var transitions: CubeTransition {
        selected.type == .f2l ? f2lTransitions : ollTransitions
    }
}

#Preview {
    ContentView()
}
