//
//  WorldTracking.swift
//  Chapter8
//
//  Created by 上山晃弘 on 2024/05/13.
//

import Foundation
import ARKit

// 現在時刻取得のためのフレームワーク
import QuartzCore

@MainActor
class WorldTracking: ObservableObject {
    private let session = ARKitSession()
    private let worldTracking = WorldTrackingProvider()
    
    func run() async {
        // ARKit の初期化とワールドトラッキング有効化
        do {
            guard WorldTrackingProvider.isSupported else { return }
            try await session.run([worldTracking])
        } catch {
            print("Error: \(error)")
        }
    }
    
    var deviceTransform: simd_float4x4? {
        // Vision Pro の現在の位置と回転を取得
        let device = worldTracking
            .queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        return device?.originFromAnchorTransform
    }
}
