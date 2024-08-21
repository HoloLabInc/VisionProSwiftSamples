//
//  ContentView.swift
//  Chapter4
//
//  Created by hiromu on 2024/08/07.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    let url = "https://developer.apple.com/augmented-reality/quick-look/models/teapot/teapot.usdz"

    var body: some View {
        Model3D(url: URL(string: url)!) { model in
            model
                .resizable()
                .aspectRatio(contentMode: .fit)
                // ドラッグ操作によるy軸回転処理を行うモディファイア
                .dragRotation()
        } placeholder: {
            ProgressView()
        }
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
