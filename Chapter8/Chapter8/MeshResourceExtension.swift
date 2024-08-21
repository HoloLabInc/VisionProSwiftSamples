//
//  MeshResourceExtension.swift
//  Chapter8
//
//  Created by 鷲尾友人 on 2024/07/06.
//

import RealityKit
import ARKit

// 下記サイトを参考に作成。
// https://forums.developer.apple.com/forums/thread/749759
// https://zenn.dev/shu223/articles/visionos_scenemesh
// https://github.com/XRealityZone/what-vision-os-can-do/blob/main/WhatVisionOSCanDo/Extension/GeometrySource.swift

extension MeshResource.Contents {
    init(geom: MeshAnchor.Geometry) {
        self.init()
        self.instances = [MeshResource.Instance(id: "main", model: "model")]
        var part = MeshResource.Part(id: "part", materialIndex: 0)
        part.positions = MeshBuffer(geom.vertices.asSIMD3(ofType: Float.self))
        part.normals = MeshBuffer(geom.normals.asSIMD3(ofType: Float.self))
        part.triangleIndices =
            MeshBuffer(geom.faces.asArray(ofType: UInt32.self))
        self.models = [MeshResource.Model(id: "model", parts: [part])]
    }
}

extension GeometrySource {
    func asArray<T>(ofType: T.Type) -> [T] {
        assert(MemoryLayout<T>.stride == stride)
        return (0 ..< self.count).map {
            buffer.contents().advanced(by: offset + stride * Int($0))
                .assumingMemoryBound(to: T.self).pointee
        }
    }

    func asSIMD3<T>(ofType: T.Type) -> [SIMD3<T>] {
        return asArray(ofType: (T, T, T).self).map { .init($0.0, $0.1, $0.2) }
    }
}

extension GeometryElement {
    func asArray<T>(ofType: T.Type) -> [T] {
        assert(MemoryLayout<T>.stride == bytesPerIndex)
        return (0 ..< self.count * self.primitive.indexCount).map {
            buffer.contents().advanced(by: bytesPerIndex * Int($0))
                .assumingMemoryBound(to: T.self).pointee
        }
    }
}
