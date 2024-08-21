//
//  HandTracking.swift
//  Chapter7
//
//  Created by 上山晃弘 on 2024/05/02.
//

import Foundation
// ARKit 利用のためインポート追加
import ARKit

// メインスレッドで実行するため @MainActor を付ける
@MainActor
// ハンドトラッキング結果の変更を View で感知するため ObservableObject にする
class HandTracking: ObservableObject {
    // 左右の人差し指の位置
    @Published var leftIndex: simd_float4x4?
    @Published var rightIndex: simd_float4x4?
    
    func run() async {
        // ARKit の初期化とハンドトラッキング有効化
        let session = ARKitSession()
        let handInfo = HandTrackingProvider()
        do {
            // ハンドトラッキングがサポートされていない実行環境なら抜ける
            guard HandTrackingProvider.isSupported else { return }
            // ARKit のハンドトラッキングを開始
            try await session.run([handInfo])
        } catch {
            print("Error: \(error)")
        }

        // ハンドトラッキングの更新処理
        for await update in handInfo.anchorUpdates {
            // トラッキング状態を確認し、トラッキング中でなければ更新を無視する
            guard update.anchor.isTracked else { continue }
            switch update.event {
            case .updated:
                if let skeleton = update.anchor.handSkeleton {
                    // 人差し指の座標取得
                    let index = skeleton.joint(.indexFingerIntermediateBase)
                        .anchorFromJointTransform
                    // 手の位置を取得
                    let root = update.anchor.originFromAnchorTransform
                    // ワールド座標系に変換
                    let worldIndex = root * index
                    // 左右を判別し、プロパティを更新
                    if update.anchor.chirality == .left {
                        leftIndex = worldIndex
                    } else {
                        rightIndex = worldIndex
                    }
                }
            default:
                break
            }
        }
    }
}

// simd_float4x4 から simd_float3 の位置を取得する拡張機能
extension simd_float4x4 {
    var position: simd_float3 {
        let pos = self.columns.3
        return simd_float3(pos.x, pos.y, pos.z)
    }
}
