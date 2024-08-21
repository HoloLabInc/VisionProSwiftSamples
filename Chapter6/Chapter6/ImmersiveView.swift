//
//  ImmersiveView.swift
//  Chapter6
//
//  Created by hiromu on 2024/08/07.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
    @Environment(AppModel.self) var model
    @State private var scene: Entity?
    private let sceneName = "Chapter6.usda"

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let scene = try? await Entity(named: "Chapter6", in: realityKitContentBundle) {
                content.add(scene)
                self.scene = scene
            }

            await setAudioInfo(info: model.audioInfo[0], named: "Cube", resource: "/Root/AudioFiles/CatMeow01")
            await setAudioInfo(info: model.audioInfo[1], named: "Cube_1", resource: "/Root/AudioFiles/DogBark02")
            await setAudioInfo(info: model.audioInfo[2], named: "AmbientAudio", resource: "/Root/AudioFiles/AtmospheresForestFloor")
            await setAudioInfo(info: model.audioInfo[3], named: "ChannelAudio", resource: "/Root/AudioFiles/AtmospheresForestFloor")
        } update: { content in
            updateMaterial(content)
        }
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                value.entity.position = value.convert(value.location3D,
                                                      from: .local,
                                                      to: value.entity.parent!)
            }
        )
    }

    private func setAudioInfo(info: AudioInfo, named: String, resource: String) async {
        // エンティティの設定
        if let entity = await scene?.findEntity(named: named) {
            info.entity = entity
        }
        // 音声データの読み込み
        info.audio = try! await AudioFileResource(named: resource, from: sceneName, in: realityKitContentBundle)
        // トグルボタンの状態初期化
        info.isPlaying = false
    }

    private func updateMaterial(_ content: RealityViewContent) {
        guard let entity = model.audioInfo[1].entity,
              var material = entity.shaderGraphMaterial else { return }

        do {
            try material.setParameter(name: "Metallic", value: .float(model.sliderValue))
            if var component = entity.modelComponent {
                component.materials = [material]
                entity.components.set(component)
            }
        } catch {
            print("Error", error)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
