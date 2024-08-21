//
//  ContentView.swift
//  Chapter7
//
//  Created by 上山晃弘 on 2024/05/01.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    // 画面遷移のための関数(環境値)
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack { // 重ねて表示
            // 背景画像を表示
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 25.0))

            // ゲームスタートボタンを表示
            Button(action: {
                Task {
                    // イマーシブスペースの起動とウインドウの削除
                    await openImmersiveSpace(id: "ImmersiveSpace")
                    dismiss()
                }
            }, label: {
                Text("Start")
                    // ボタンの文字サイズを大きく設定
                    .font(.extraLargeTitle)
                    .padding()
            })
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
