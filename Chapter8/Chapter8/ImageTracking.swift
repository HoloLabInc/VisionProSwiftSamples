//
//  ImageTracking.swift
//  Chapter8
//
//  Created by 上山晃弘 on 2024/05/13.
//

import Foundation
import SwiftUI
import ARKit
import RealityKit

@MainActor
class ImageTracking: ObservableObject {
    // 画像の位置と回転
    @Published var imageTransform: simd_float4x4?

    func run() async {
        // マーカー画像の読み込み
        guard let image = UIImage(named: "background")?.cgImage else { return }
        let referenceImage = ReferenceImage(
            cgimage: image,
            physicalSize: CGSize(width: 0.16, height: 0.09)
        )

        // ARKit の初期化と画像トラッキングの有効化
        let session = ARKitSession()
        let imageTrackingProvider =
            ImageTrackingProvider(referenceImages: [referenceImage])
        do {
            guard ImageTrackingProvider.isSupported else { return }
            try await session.run([imageTrackingProvider])
        } catch {
            print("Error: \(error)")
        }

        // 画像トラッキングの更新処理
        for await update in imageTrackingProvider.anchorUpdates {
            switch update.event {
            case .added:
                break
            case .updated:
                // 画像の位置を更新
                imageTransform = update.anchor.originFromAnchorTransform
            case .removed:
                break
            }
        }
    }
}
