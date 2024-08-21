//
//  SceneReconstruction.swift
//  Chapter8
//
//  Created by 上山晃弘 on 2024/05/13.
//

import Foundation
import ARKit
import RealityKit

@MainActor
class SceneReconstruction: ObservableObject {
    // 障害物をまとめて保持するルート Entity
    var root = Entity()
    // 障害物の管理用辞書
    private var meshEntities = [UUID: ModelEntity]()

    func run() async {
        // ARKit の初期化とシーン再構築の有効化
        let session = ARKitSession()
        let sceneReconstruction = SceneReconstructionProvider()
        do {
            guard SceneReconstructionProvider.isSupported else { return }
            try await session.run([sceneReconstruction])
        } catch {
            print("Error: \(error)")
        }
        
        // 障害物の更新処理
        for await update in sceneReconstruction.anchorUpdates {
            let meshAnchor = update.anchor
            // 障害物用のメッシュを作成
            guard let shape = try? await ShapeResource
                .generateStaticMesh(from: meshAnchor) else { continue }
            guard let mesh = try? await MeshResource(
                from: MeshResource.Contents(geom: meshAnchor.geometry)
            ) else { continue }
            switch update.event {
            // 障害物が新規に追加された場合
            case .added:
                // 追加された物体から障害物 Entity を作成、隠面処理と物理演算機能を追加
                let entity = ModelEntity(
                    mesh: mesh,
                    materials: [OcclusionMaterial()]
                )
                entity.transform = Transform(
                    matrix: meshAnchor.originFromAnchorTransform
                )
                entity.collision = CollisionComponent(
                    shapes: [shape],
                    isStatic: true
                )
                entity.components.set(InputTargetComponent())
                entity.physicsBody = PhysicsBodyComponent(mode: .static)
                // 管理用辞書とルート Entity に追加
                meshEntities[meshAnchor.id] = entity
                root.addChild(entity)
            // 障害物の形状がアップデートされた場合
            case .updated:
                // 物体の id を取得して形状と位置を更新
                guard let entity = meshEntities[meshAnchor.id] else { continue }
                entity.model?.mesh = mesh
                entity.transform = Transform(
                    matrix: meshAnchor.originFromAnchorTransform
                )
                entity.collision?.shapes = [shape]
            // 障害物が削除された場合
            case .removed:
                // 物体の id を取得し管理用辞書とルート Entity から削除
                meshEntities[meshAnchor.id]?.removeFromParent()
                meshEntities.removeValue(forKey: meshAnchor.id)
            }
        }
    }
}
