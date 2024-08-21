//
//  ImmersiveView.swift
//  Chapter5
//
//  Created by hiromu on 2024/08/07.
//

import RealityKit
import RealityKitContent
import SwiftUI

struct ImmersiveView: View {
    @State private var earth: Entity?
    @State private var moon: Entity?
    @State private var rocket: Entity?

    var body: some View {
        RealityView { content, attachments in
            if let earth = try? await Entity(named: "Earth", in: realityKitContentBundle) {
                earth.components.set([InputTargetComponent()])
                let shape = ShapeResource.generateSphere(radius: 0.1)
                earth.components.set(CollisionComponent(shapes: [shape]))
                earth.position = [-1, 1, -1]
                content.add(earth)
                self.earth = earth
            }

            if let moon = try? await Entity(named: "Moon", in: realityKitContentBundle) {
                moon.components.set([InputTargetComponent()])
                let shape = ShapeResource.generateSphere(radius: 0.1)
                moon.components.set(CollisionComponent(shapes: [shape]))
                moon.position = [1, 1, -1]
                content.add(moon)
                self.moon = moon
            }

            if let rocket = try? await Entity(named: "ToyRocket", in: realityKitContentBundle) {
                // ロケットにカスタムコンポーネントを設定
                rocket.components.set([MoveComponent()])
                rocket.position = [0, 1, -1]
                content.add(rocket)
                self.rocket = rocket
            }

            if let earthAttachment = attachments.entity(for: "earth_label") {
                earthAttachment.position = [0, -0.15, 0]
                earth?.addChild(earthAttachment)
            }

            if let moonAttachment = attachments.entity(for: "moon_label") {
                moonAttachment.position = [0, -0.15, 0]
                moon?.addChild(moonAttachment)
            }
        } update: { _, _ in
        } attachments: {
            // SwiftUI Views
            Attachment(id: "earth_label") {
                Text("Earth")
                    .font(.largeTitle)
                    .frame(width: 200, height: 60)
                    .glassBackgroundEffect()
            }
            Attachment(id: "moon_label") {
                Text("Moon")
                    .font(.largeTitle)
                    .frame(width: 200, height: 60)
                    .glassBackgroundEffect()
            }
        }
        // タップジェスチャに対応する
        .gesture(SpatialTapGesture()
            // 任意のエンティティを操作の対象とする
            .targetedToAnyEntity()
            // タップジェスチャが終了した時(つまり親指と人差し指を離した時)の動作を定義
            .onEnded { value in
                // 各エンティティがnilでないことをチェックする
                guard let earth = self.earth, let moon = self.moon, let rocket = self.rocket else { return }

                if value.entity == earth {
                    // コンポーネントの値設定
                    if var component: MoveComponent = rocket.components[MoveComponent.self] {
                        component.speed = -0.7
                        component.start = moon.position
                        component.end = earth.position + [0.25, 0, 0]
                        component.isEnabled = true
                        rocket.components[MoveComponent.self] = component
                    }
                    // Z軸周りにπ/2ラジアン（90度）回転するためのクォータニオンを生成
                    let rotation = simd_quatf(angle: .pi / 2, axis: SIMD3<Float>(0, 0, 1))
                    // ロケットの回転
                    rocket.orientation = rotation
                } else if value.entity == moon {
                    if var component: MoveComponent = rocket.components[MoveComponent.self] {
                        component.speed = 0.7
                        component.start = earth.position
                        component.end = moon.position - [0.25, 0, 0]
                        component.isEnabled = true
                        rocket.components[MoveComponent.self] = component
                    }
                    // Z軸周りに-π/2ラジアン（-90度）回転するためのクォータニオンを生成
                    let rotation = simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 0, 1))
                    // ロケットの回転
                    rocket.orientation = rotation
                }
            })
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
