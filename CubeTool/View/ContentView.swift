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
    @State private var selected: CubeStateIndex = .init(type: .f2l, index: 0)
    
    /// F2L 状态转换
    private let f2lTransitions = CubeTransition.from(systemName: "F2L-transition")
    /// OLL 状态转换
    private let ollTransitions = CubeTransition.from(systemName: "OLL-transition")
    
    private let cubeView = CubeView()
    
    @State private var curTransition: [String: CubeFormula] = [:]
    @State private var autoChangeState = false

    @AppStorage("op-duration") private var duration: Double = 0.2
    
    @Namespace private var namespace
    
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
                                    .frame(width: 38, height: 56)
                                    .onTapGesture {
                                        withAnimation {
                                            selected = .f2l(i)
                                            curTransition = transitions.transition[index.indexString] ?? [:]
                                        }
                                    }
                                    .padding(4)
                                    .padding(.trailing, 2)
                                    .background(RoundedRectangle(cornerRadius: 4)
                                        .fill(selected == index ? Color.accentColor : .clear))
                                    .matchedGeometryEffect(id: index, in: namespace)
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
                                let index =  CubeStateIndex.oll(i)
                                CubeStateThumbnail(index: index)
                                    .frame(width: 36, height: 56)
                                    .onTapGesture {
                                        withAnimation {
                                            selected = index
                                            curTransition = transitions.transition[index.indexString] ?? [:]
                                        }
                                    }
                                    .padding(4)
                                    .padding(.trailing, 4)
                                    .background(RoundedRectangle(cornerRadius: 4)
                                        .fill(selected == index ? Color.accentColor : .clear))
                                    .matchedGeometryEffect(id: index, in: namespace)
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 360)
        }, detail: {
            HStack {
                ScrollView {
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
                                        } else {
                                            Text("式")
                                                .foregroundColor(.green)
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
                                            let o: CubeStateIndex = selected.update(newIndex: originIndex)
                                            CubeStateThumbnail(index: o)
                                                .frame(width: 36, height: 54)
                                            stepView(formulaKey: formulaKey)
                                        }
                                        VStack {
                                            Image(systemName: "mappin.and.ellipse")
                                                .font(.title)
                                            Text(selected.indexString)
                                        }
                                        .bold()
                                        
                                        stepView(formulaKey: formulaKey)
                                        
                                        let o: CubeStateIndex = selected.update(newIndex: Int(key) ?? 0)
                                        CubeStateThumbnail(index: o)
                                            .frame(width: 36, height: 54)
                                    }
                                }
                            }
                            .onTapGesture {
                                // formula = curTransition[key]
                                cubeView.exec(transitions.completeFormula(curTransition[key]), duration: duration) {
                                    if self.autoChangeState {
                                        let name = key
                                        logger.info("切换状态:\(name)")
                                        selected = selected.type == .f2l ? .f2l(Int(name) ?? 0) : .oll(Int(name) ?? 0)
                                        curTransition = transitions.transition[name] ?? [:]
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                }
                
                Spacer()
                VStack {
                    HStack {
                        Slider(value: $duration, in: 0 ... 1, step: 0.05)
                        Text("\(Int(duration * 1000)) ms")
                        Button("Reset", action: {
                            if let cube = Cube(systemName: selected.filename) {
                                cubeView.performCube(cube)
                            }
                        })
                        
                        Button("Print") {
                            cubeView.printCube()
                        }
                    }
                    cubeView
                        .frame(width: 300, height: 300)
                    
                    TextField("", text: $formula)
                        .onSubmit {
                            cubeView.exec(formula, duration: duration)
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
    func stepView(formulaKey: CubeFormula) -> some View {
        VStack {
            Text(formulaKey.type == .key ? formulaKey.value : "")
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
