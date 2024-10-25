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

    var body: some View {
        VStack {
            cubeView
                .frame(width: 300, height: 300)

            TextField("", text: $formula)
                .onSubmit {
                    cubeView.exec(formula)
                }
            
            Button("Print") {
                cubeView.printCube()
            }
        }
    }
}

#Preview {
    ContentView()
}
