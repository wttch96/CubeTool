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

//    var body: some View {
//        NavigationSplitView(sidebar: {
//            List {
//                Section("F2L") {
//                    VStack {
//                        LazyVGrid(columns: [
//                            GridItem(.adaptive(minimum: 40)),
//                            GridItem(.adaptive(minimum: 40)),
//                            GridItem(.adaptive(minimum: 40)),
//                            GridItem(.adaptive(minimum: 40))
//                        ]) {
//                            ForEach(0 ... 41, id: \.self) { i in
//                                let index = CubeStateIndex.f2l(i)
//                                CubeStateThumbnail(index: index)
//                                    .frame(width: 38, height: 56)
//                                    .onTapGesture {
//                                        withAnimation {
//                                            selected = .f2l(i)
//                                        }
//                                    }
//                                    .padding(4)
//                                    .padding(.trailing, 2)
//                                    .background(RoundedRectangle(cornerRadius: 4)
//                                        .fill(selected == index ? Color.accentColor : .clear))
//                                    .matchedGeometryEffect(id: index, in: namespace)
//                            }
//                        }
//                        Spacer()
//                    }
//                }
//
//                Section("OLL") {
//                    VStack {
//                        LazyVGrid(columns: [
//                            GridItem(.adaptive(minimum: 40)),
//                            GridItem(.adaptive(minimum: 40)),
//                            GridItem(.adaptive(minimum: 40)),
//                            GridItem(.adaptive(minimum: 40))
//                        ]) {
//                            ForEach(0 ... 57, id: \.self) { i in
//                                let index = CubeStateIndex.oll(i)
//                                CubeStateThumbnail(index: index)
//                                    .frame(width: 36, height: 56)
//                                    .onTapGesture {
//                                        withAnimation {
//                                            selected = index
//                                        }
//                                    }
//                                    .padding(4)
//                                    .padding(.trailing, 4)
//                                    .background(RoundedRectangle(cornerRadius: 4)
//                                        .fill(selected == index ? Color.accentColor : .clear))
//                                    .matchedGeometryEffect(id: index, in: namespace)
//                            }
//                        }
//                    }
//                }
//            }
//        }, detail: {
//            VStack {
//                Toggle("完成后自动切换状态", isOn: $autoChangeState)
//                HStack {
//                    Spacer()
//
//                    ScrollView {
//                        VStack(alignment: .leading) {
//                            ForEach(Array(statesLeadingTo.keys), id: \.self) { state in
//                                if let formulaKey = statesLeadingTo[state] {
//                                    let o: CubeStateIndex = selected.update(newIndex: Int(state) ?? 0)
//                                    HStack {
//                                        Spacer()
//                                        VStack(alignment: .trailing) {
//                                            if let key = formulaKey.key {
//                                                Text(key)
//                                            }
//                                            Text(transitions.completeFormula(formulaKey))
//                                                .font(.title3)
//                                                .bold()
//                                        }
//                                        .offset(y: -8)
//                                        CubeStateThumbnail(index: o)
//                                            .frame(width: 48, height: 64)
//                                    }
//                                    .onTapGesture {
//                                        if let cube = Cube(systemName: o.filename) {
//                                            cubeView.performCube(cube)
//                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                                cubeView.exec(self.transitions.completeFormula(formulaKey), duration: duration) {}
//                                            }
//                                        }
//                                    }
//                                }
//                            }
//                            Spacer()
//                        }
//                        .frame(width: 300)
//                        .padding(.trailing)
//                    }
//
//                    HStack {
//                        Image(systemName: "arrowshape.right")
//                        VStack {
//                            Image(systemName: "mappin.and.ellipse")
//                                .font(.title)
//                            Text(selected.indexString)
//                        }
//                        Image(systemName: "arrowshape.right")
//                    }
//                    .bold()
//
//                    ScrollView {
//                        VStack {
//                            // 可以转换的状态
//                            ForEach(curTransition, id: \.self) { formulaKey in
//                                VStack(alignment: .trailing) {
//                                    let o: CubeStateIndex = selected.update(newIndex: formulaKey.reach)
//
//                                    HStack {
//                                        CubeStateThumbnail(index: o)
//                                            .frame(width: 48, height: 64)
//                                        VStack(alignment: .leading) {
//                                            if let key = formulaKey.key {
//                                                Text(key)
//                                            }
//                                            HStack(spacing: 2) {
//                                                if let prefix = formulaKey.prefix {
//                                                    Text(prefix)
//                                                        .foregroundColor(.red)
//                                                }
//                                                Text(transitions.formula(formulaKey))
//                                                if let suffix = formulaKey.suffix {
//                                                    Text(suffix)
//                                                        .foregroundColor(.blue)
//                                                }
//                                            }
//                                            .font(.title3)
//                                            .bold()
//
//                                            if let comment = formulaKey.comment {
//                                                Text(comment)
//                                                    .font(.footnote)
//                                            }
//                                        }
//                                        .offset(y: -8)
//                                        Spacer()
//                                    }
//                                }
//                                .onTapGesture {
//                                    cubeView.exec(transitions.completeFormula(formulaKey), duration: duration) {
//                                        if self.autoChangeState {
//                                            let reach = formulaKey.reach
//                                            logger.info("切换状态:\(reach)")
//                                            selected = selected.update(newIndex: reach)
//                                        }
//                                    }
//                                }
//                            }
//                            Spacer()
//                        }
//                        .frame(width: 300)
//                    }
//                    Spacer()
//                }
//                .padding()
//
//                Spacer()
//
//                VStack {
//                    HStack {
//                        Slider(value: $duration, in: 0 ... 1, step: 0.05)
//                        Text("\(Int(duration * 1000)) ms")
//                        Button("Reset", action: {
//                            if let cube = Cube(systemName: selected.filename) {
//                                cubeView.performCube(cube)
//                            }
//                        })
//
//                        Button("Print") {
//                            cubeView.printCube()
//                        }
//                        Button("FRUR'U'F'") {
//                            cubeView.exec("FRUR'U'F'", duration: duration)
//                        }
//                    }
//                    cubeView
//                        .frame(width: 300, height: 300)
//
//                    TextField("", text: $formula)
//                        .onSubmit {
//                            cubeView.exec(formula, duration: duration)
//                        }
//
//                    Spacer()
//                }
//            }
//        })
//        .edgesIgnoringSafeArea(.all)
//        .navigationTitle(selected.indexString)
//        .onChange(of: selected) { _, newValue in
//            curTransition = transitions.transition[newValue.indexString] ?? []
//            statesLeadingTo = transitions.statesLeadingTo(currentState: newValue.index)
//
//            if let cube = Cube(systemName: newValue.filename) {
//                cubeView.performCube(cube)
//            }
//        }
//    }
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
