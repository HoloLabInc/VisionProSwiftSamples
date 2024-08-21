//
//  ImmersiveView.swift
//  Chapter7
//
//  Created by 上山晃弘 on 2024/05/01.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    // 画面遷移のための関数(環境値)
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    // ゲームロジック
    @StateObject var logic = ShootingLogic()
    // 弾 Entity
    @State var bullet: ModelEntity?
    // ARKit のハンドトラッキング機能
    @StateObject var handTracking = HandTracking()
    
    var body: some View {
        RealityView { content, attachments in
            // 弾モデルの読み込み
            if let bulletScene = try? await Entity(
                named: "Bullet",
                in: realityKitContentBundle
            ) {
                bullet = bulletScene
                    .findEntity(named: "Sphere") as? ModelEntity
            }

            // ターゲットモデルの読み込み
            if let targetScene = try? await Entity(
                named: "Target",
                in: realityKitContentBundle
            ) {
                if let target = targetScene.findEntity(named: "Robot") {
                    // ターゲット管理用 Entity への追加
                    logic.targetRoot.position = simd_float3(0, 1, -1)
                    logic.targetRoot.addChild(target)

                    // 当たり判定処理
                    _ = content.subscribe(
                        to: CollisionEvents.Began.self,
                        on: target
                    ) {
                        event in
                        // ゲームロジックの当たり判定処理呼び出し
                        logic.hit(event)
                    }

                    // ターゲットに UI を追加
                    if let attachedUI = attachments.entity(for: "Menu") {
                        target.addChild(attachedUI)
                    }
                }
            }

            // ターゲットと弾の管理用 Entity のコンテンツへの追加
            content.add(logic.bulletRoot)
            content.add(logic.targetRoot)
        } update: { content, attachments in
            // カスタムジェスチャーの判定処理
            if let leftIndex = handTracking.leftIndex,
               let rightIndex = handTracking.rightIndex
            {
                if distance(leftIndex.position, rightIndex.position) < 0.04 {
                    // ゲームロジックの弾発射処理呼び出し
                    logic.shoot(
                        bullet: bullet,
                        position: leftIndex.position,
                        velocity: SIMD3(0, 0, -1)
                    )
                }
            }
        } attachments: {
            // RealityKit 内で表示される UI の設定
            Attachment(id: "Menu") {
                VStack {
                    // 得点、残り時間の表示
                    // ゲームロジックから得点と残り時間を取得
                    Text("Score: \(logic.score) Time: \(Int(logic.time))")
                        .font(.extraLargeTitle)
                    Spacer()
                    HStack {
                        // デバッグ用の発射ボタン
                        #if targetEnvironment(simulator)
                        Button("Shoot") {
                            logic.shoot(
                                bullet: bullet,
                                position: SIMD3(0, 1.2, -0.5),
                                velocity: SIMD3(0, 0, -5)
                            )
                        }
                        #endif
                        // リセットボタン
                        Button("Reset") {
                            // ゲームロジックのリセット処理呼び出し
                            logic.reset()
                        }
                        // 終了ボタン
                        Button("Exit") {
                            Task {
                                // ウインドウの表示とイマーシブスペースの削除
                                openWindow(id: "Window")
                                await dismissImmersiveSpace()
                            }
                        }
                    }
                    Spacer()
                }
                // 3D モデルの前に UI を表示
                .offset(z: 100)
            }
        }.task {
            // ゲームロジックの実行
            await logic.run()
        }.task {
            // ハンドトラッキング処理
            await handTracking.run()
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
