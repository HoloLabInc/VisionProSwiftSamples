//
//  ContentView.swift
//  Chapter6
//
//  Created by hiromu on 2024/08/07.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ContentView: View {
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @Environment(AppModel.self) var model

    var body: some View {
        @Bindable var model = model

        VStack {
            Text("Reality Composer Pro Sample")
                .font(.title)

            Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                .font(.title)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()

            VStack {
                CustomToggle("Spatial Audio(Cat)", info: model.audioInfo[0])
                CustomToggle("Spatial Audio(Dog)", info: model.audioInfo[1])
                CustomToggle("Ambient Audio", info: model.audioInfo[2])
                CustomToggle("Channel Audio", info: model.audioInfo[3])

                HStack {
                    Text("Metallic")
                        .font(.title)
                    Slider(value: $model.sliderValue, in: 0.0 ... 1.0)
                }
                .frame(width: 360)
            }
            .glassBackgroundEffect()
            .disabled(!immersiveSpaceIsShown)
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
    }

    private func CustomToggle(_ label: String, info: AudioInfo) -> some View {
        // トグルボタン押下時に所定の処理を実行する
        Toggle(label, isOn: binding(info: info))
            .font(.title)
            .frame(width: 360)
            .padding(24)
    }

    private func binding(info: AudioInfo) -> Binding<Bool> {
        Binding<Bool>(
            get: { info.isPlaying },
            set: { _ in
                model.toggleAudio(info: info)
            }
        )
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
