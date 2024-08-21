//
//  EntityExtension.swift
//  Chapter6
//
//  Created by hiromu on 2024/08/07.
//

import RealityKit

extension Entity {
    var modelComponent: ModelComponent? {
        components[ModelComponent.self]
    }

    var shaderGraphMaterial: ShaderGraphMaterial? {
        modelComponent?.materials.first as? ShaderGraphMaterial
    }
}
