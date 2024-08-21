//
//  ShootingLogic.swift
//  Chapter8
//
//  Created by 上山晃弘 on 2024/05/13.
//

import Foundation
import RealityKit

@MainActor
class ShootingLogic: ObservableObject {
    // 弾管理用 Entity
    var bulletRoot = Entity()
    // ターゲット管理用 Entity
    var targetRoot = Entity()
    // 残り時間
    @Published var time: Float = 30
    // 得点
    @Published var score: Int = 0
    // 前回の発射時間
    private var previousTime: Float = 30

    // 残り時間処理とターゲット移動処理
    func run() async {
        while true {
            // 200Hzで更新する
            let interval: Float = 1.0 / 200
            let intervalNanos = UInt64(Float(NSEC_PER_SEC) * interval)
            do {
                try await Task.sleep(nanoseconds: intervalNanos)
            } catch {
                return // タスクがキャンセルされた
            }

            time -= interval
            if time < 0.0 {
                time = 0.0
            } else {
                targetRoot.children.first?.position =
                    simd_float3(sin(time / 2.0) / 2.0, 0, 0)
            }
        }
    }

    // リセット処理
    func reset() {
        bulletRoot.children.removeAll()
        score = 0
        time = 30
        previousTime = 30
    }

    // 弾の発射処理
    func shoot(
        bullet: ModelEntity?,
        position: simd_float3,
        velocity: simd_float3,
        // 弾発射時のアクション
        shootAction: () -> Void
    ) {
        // 発射間隔の制御
        guard time > 0.0 && previousTime - time >= 0.1 else { return }
        previousTime = time
        // 弾 Entity の複製と発射処理
        if let bullet {
            let bulletClone = bullet.clone(recursive: true)
            bulletClone.position = position
            bulletClone.physicsMotion?.linearVelocity = velocity
            bulletRoot.addChild(bulletClone)
            // アクションのコールバック
            shootAction()
        }
    }

    // ターゲットに弾が当たった時の処理
    func hit(
        _ event: CollisionEvents.Began,
        // 命中時のアクション
        hitAction: () -> Void
    ) {
        // 弾 Entity の削除と得点加算
        if event.entityA.name != event.entityB.name {
            score += 1
            event.entityB.removeFromParent()
            // アクションのコールバック
            hitAction()
        }
    }
}
