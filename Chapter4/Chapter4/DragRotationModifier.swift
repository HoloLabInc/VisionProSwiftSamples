//
//  DragRotationModifier.swift
//  Chapter4
//
//  Created by hiromu on 2024/08/07.
//

import SwiftUI

extension View {
    /// エンティティをドラッグして回転させることができる
    func dragRotation(sensitivity: Double = 10) -> some View {
        modifier(DragRotationModifier(sensitivity: sensitivity))
    }
}

// ドラッグジェスチャをエンティティの回転に変換するモディファイア
private struct DragRotationModifier: ViewModifier {
    // 回転量の感度
    let sensitivity: Double
    // 現在の回転角度
    @State private var yaw: Double = 0
    // 回転の基本角度
    @State private var baseYaw: Double = 0

    func body(content: Content) -> some View {
        content
            // y軸に沿ってyawラジアン回転する
            .rotation3DEffect(.radians(yaw), axis: .y)
            // ドラッグジェスチャを有効にする
            .gesture(DragGesture(minimumDistance: 0.0)
                // 任意のエンティティを操作の対象とする
                .targetedToAnyEntity()
                // ドラッグ中の動作を定義
                .onChanged { value in
                    // 現在の直線変位を求める
                    let location3D = value.convert(value.location3D, from: .local, to: .scene)
                    let startLocation3D = value.convert(value.startLocation3D, from: .local, to: .scene)
                    let delta = location3D - startLocation3D
                    // ここで更新されたyawがrotation3DEffectに反映されて回転する
                    yaw = baseYaw + Double(delta.x) * sensitivity
                }
                // ドラッグが終了した時の動作を定義
                .onEnded { _ in
                    // 次のジェスチャで使用するために最後の値を保存する
                    baseYaw = yaw
                })
    }
}
