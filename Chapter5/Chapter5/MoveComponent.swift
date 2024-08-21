//
//  MoveComponent.swift
//  Chapter5
//
//  Created by hiromu on 2024/08/07.
//

import RealityKit
import SwiftUI

struct MoveComponent: Component {
    var speed: Float
    var start: SIMD3<Float>
    var end: SIMD3<Float>
    var isEnabled: Bool

    init(speed: Float = 0.5, start: SIMD3<Float> = [-1, 1, -1], end: SIMD3<Float> = [1, 1, -1], isEnabled: Bool = false) {
        self.speed = speed
        self.start = start
        self.end = end
        self.isEnabled = isEnabled
    }
}

struct MoveSystem: System {
    static let query = EntityQuery(where: .has(MoveComponent.self))

    init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var component: MoveComponent = entity.components[MoveComponent.self] else { continue }
            if component.isEnabled {
                if abs(entity.position.x - component.end.x) > 0.1 {
                    entity.setPosition([entity.position.x + component.speed * Float(context.deltaTime), 1, -1], relativeTo: nil)
                } else {
                    component.isEnabled = false
                }
            }
        }
    }
}
