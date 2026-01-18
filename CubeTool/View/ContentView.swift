//
//  ContentView.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var formula = ""
    @State private var title = ""
    
    @State private var curTransition: [CubeFormula] = []
    @AppStorage("auto-change-state") private var autoChangeState = false
    @State private var statesLeadingTo: [String: CubeFormula] = [:]
    @State private var cubeStateType: CubeStateType = .f2l
    
    @Namespace private var namespace
    
    private let stateSections = StateSection.load(systemName: "StateList")
    
    var body: some View {
        NavigationSplitView(sidebar: {
            Picker("", selection: $cubeStateType, content: {
                ForEach(CubeStateType.allCases, content: { type in
                    Text(type.rawValue).tag(type)
                })
            })
            .pickerStyle(.segmented)
            List {
                ForEach(stateList, id: \.title) { section in
                    Section(section.title) {
                        ForEach(section.state, id: \.self) { index in
                            let index = CubeStateIndex(type: cubeStateType, index: index)
                            NavigationLink(value: index, label: {
                                HStack {
                                    index.thumbnailImage
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 64)
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        if let formula = ResourceUtil.shared.solve(index) {
                                            Text(ResourceUtil.shared.transitions(of: cubeStateType).completeFormula(formula))
                                                .bold()
                                        }
                                        Text(index.indexString)
                                            .font(.footnote)
                                    }
                                }
                            })
                        }
                    }
                }
            }
#if os(macOS)
            .tabViewStyle(.grouped)
#endif
            .navigationDestination(for: CubeStateIndex.self, destination: { index in
                CubeStateView(index: index)
            })
            
        }, detail: {})
    }
}

extension ContentView {
    var stateList: [StateSection] {
        stateSections[cubeStateType] ?? []
    }

    @ViewBuilder
    func stepView(formulaKey: CubeFormula) -> some View {
        VStack {
            if let key = formulaKey.key {
                Text(key)
                    .font(.footnote)
            }
            Image(systemName: "arrowshape.right")
        }
        .offset(y: -12)
    }

//    var transitions: CubeTransition {
//        selected.type == .f2l ? f2lTransitions : ollTransitions
//    }
}

#Preview {
    ContentView()
}
