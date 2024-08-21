//
//  ImmersiveView.swift
//  Chapter9
//
//  Created by hiromu on 2024/08/07.
//

import RealityKit
import SwiftUI

struct ImmersiveView: View {
    @State var manager: GroupActivityManager

    var body: some View {
        RealityView { content in
            manager.entity = ModelEntity(
                mesh: .generateBox(size: 0.1),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            guard let entity = manager.entity else { return }
            let shape = ShapeResource.generateBox(size: [0.1, 0.1, 0.1])
            entity.collision = CollisionComponent(shapes: [shape])
            entity.components.set([InputTargetComponent()])
            content.add(entity)
        } update: { _ in
            guard let entity = manager.entity, manager.isSharePlaying else { return }
            entity.transform = Transform(matrix: simd_float4x4(manager.pose))
            entity.scale = [1, 1, 1]
        }
        .simultaneousGesture(DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard let entity = manager.entity else { return }
                entity.position = value.convert(
                    value.location3D,
                    from: .local,
                    to: .scene
                )
                // メッセージの送信
                let pose = Pose3D(position: entity.position, rotation: entity.orientation)
                manager.sendPoseMessage(message: PoseMessage(pose: pose))
            })
        .simultaneousGesture(RotateGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                guard let entity = manager.entity else { return }
                entity.setOrientation(
                    .init(
                        angle: Float(value.rotation.degrees / 10),
                        axis: [0, 1, 0]
                    ),
                    relativeTo: nil
                )
                // メッセージの送信
                let pose = Pose3D(position: entity.position, rotation: entity.orientation)
                manager.sendPoseMessage(message: PoseMessage(pose: pose))
            })
    }
}

#Preview() {
    ImmersiveView(manager: GroupActivityManager())
}
