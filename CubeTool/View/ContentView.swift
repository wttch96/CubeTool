//
//  ContentView.swift
//  CubeTool
//
//  Created by Wttch on 2024/10/24.
//

import SwiftUI

struct ContentView: View {
    private let cubeView = CubeView()

    @State private var formula = ""
    @State private var title = ""
    @State private var selected: String = ""

    var body: some View {
        NavigationSplitView(sidebar: {
            List(selection: $selected) {
                Section("F2L") {
                    ForEach(1 ... 41, id: \.self) { i in
                        let name = String(format: "%02d", i)
                        NavigationLink(name, value: "F2L-" + name)
                    }
                }
            }
        }, detail: {
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
            .padding()
        })
        .navigationTitle(selected)
        .onChange(of: selected) { _, newValue in
            if let cube = Cube(systemName: newValue) {
                cubeView.performCube(cube)
            }
        }
    }
}

#Preview {
    ContentView()
}
