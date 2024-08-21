//
//  ImmersiveView.swift
//  Chapter8
//
//  Created by 上山晃弘 on 2024/05/11.
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
    // ARKit のワールドトラッキング機能
    @StateObject var worldTracking = WorldTracking()
    // ARKit のシーン再構築機能
    @StateObject var sceneReconstruction = SceneReconstruction()
    // ARKit の画像トラッキング機能
    @StateObject var imageTracking = ImageTracking()
    // 弾発射音
    @State var bulletAudio: AudioPlaybackController?
    // ターゲットへの命中音
    @State var targetAudio: AudioPlaybackController?

    var body: some View {
        RealityView { content, attachments in
            // 弾モデルの読み込み
            if let bulletScene = try? await Entity(
                named: "Bullet",
                in: realityKitContentBundle
            ) {
                bullet = bulletScene
                    .findEntity(named: "Sphere") as? ModelEntity
                // 弾発射音の読み込み
                if let audioEnt = bulletScene.findEntity(named: "SpatialAudio"),
                   let resource = try? await AudioFileResource(
                       named: "/Root/shoot_mp3",
                       from: "Bullet.usda",
                       in: realityKitContentBundle
                   )
                {
                    bulletAudio = audioEnt.prepareAudio(resource)
                    content.add(audioEnt)
                }
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
                        logic.hit(event) {
                            // 命中音再生
                            targetAudio?.entity?.position =
                                event.entityB.position
                            targetAudio?.stop()
                            targetAudio?.play()
                        }
                    }

                    // ターゲットに UI を追加
                    if let attachedUI = attachments.entity(for: "Menu") {
                        target.addChild(attachedUI)
                    }
                }

                // 命中音の読み込み
                if let audioEnt = targetScene.findEntity(named: "SpatialAudio"),
                   let resource = try? await AudioFileResource(
                       named: "/Root/hit_mp3",
                       from: "Target.usda",
                       in: realityKitContentBundle
                   )
                {
                    targetAudio = audioEnt.prepareAudio(resource)
                    content.add(audioEnt)
                }

                // BGM の読み込み
                if let audioEnt = targetScene.findEntity(named: "AmbientAudio"),
                   let resource = try? await AudioFileResource(
                       named: "/Root/bgm_mp3",
                       from: "Target.usda",
                       in: realityKitContentBundle
                   )
                {
                    let audio = audioEnt.prepareAudio(resource)
                    content.add(audioEnt)
                    // BGM の再生
                    audio.play()
                }
            }

            // ターゲットと弾の管理用 Entity のコンテンツへの追加
            content.add(logic.bulletRoot)
            content.add(logic.targetRoot)

            // シーン再構築で作られた障害物を追加
            content.add(sceneReconstruction.root)
        } update: { content, attachments in
            // ターゲットをトラッキングされた画像の位置に設定
            if let image = imageTracking.imageTransform {
                logic.targetRoot.transform.matrix = image
            }

            // カスタムジェスチャーの判定処理
            if let leftIndex = handTracking.leftIndex,
               let rightIndex = handTracking.rightIndex
            {
                if distance(leftIndex.position, rightIndex.position) < 0.04 {
                    // Vision Pro の位置と回転を取得
                    if let device = worldTracking.deviceTransform {
                        // Vision Pro の方向ベクトルを計算
                        let vec = device * simd_float4(0, 0, -1, 0)
                        // ゲームロジックの弾発射処理呼び出し
                        logic.shoot(
                            bullet: bullet,
                            position: leftIndex.position,
                            // Vision Pro の方向ベクトルを初速度に適応
                            velocity: simd_float3(vec.x, vec.y, vec.z) * 5
                        ) {
                            // 発射音再生
                            bulletAudio?.entity?.position = leftIndex.position
                            bulletAudio?.stop()
                            bulletAudio?.play()
                        }
                    }
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
                            ) {
                                // 発射音再生
                                bulletAudio?.entity?.position =
                                    SIMD3(0, 1.2, -0.5)
                                bulletAudio?.stop()
                                bulletAudio?.play()
                            }
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
        }.task {
            // ワールドトラッキング処理
            await worldTracking.run()
        }.task {
            // シーン再構築処理
            await sceneReconstruction.run()
        }.task {
            // 画像トラッキング処理
            await imageTracking.run()
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
}
