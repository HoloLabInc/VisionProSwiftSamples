//
//  ContentView.swift
//  Chapter9
//
//  Created by hiromu on 2024/08/07.
//

import GroupActivities
import SwiftUI

struct ContentView: View {
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    @State var manager: GroupActivityManager
    @StateObject private var groupStateObserver = GroupStateObserver()

    var body: some View {
        VStack {
            Text("SharePlay Sample")

            if !manager.isSharePlaying {
                Button("Start SharePlay") {
                    manager.startSession()
                }
                // SharePlay時にしか有効にならないボタン
                .disabled(!groupStateObserver.isEligibleForGroupSession)
            } else {
                Button("Leave") {
                    manager.endSession()
                }
            }

            Text(manager.emoji.symbol)
                .font(.system(size: 200))

            HStack {
                Button("嬉しい") {
                    manager.emoji = .happy
                    manager.sendEmojiMessage(message: EmojiMessage(emoji: .happy))
                }
                Button("怒り") {
                    manager.emoji = .angry
                    manager.sendEmojiMessage(message: EmojiMessage(emoji: .angry))
                }
                Button("悲しい") {
                    manager.emoji = .sad
                    manager.sendEmojiMessage(message: EmojiMessage(emoji: .sad))
                }
                Button("楽しい") {
                    manager.emoji = .laughing
                    manager.sendEmojiMessage(message: EmojiMessage(emoji: .laughing))
                }
            }

            Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
                .font(.title)
                .frame(width: 360)
                .padding(24)
                .glassBackgroundEffect()
        }
        .padding()
        .onChange(of: showImmersiveSpace) { _, newValue in
            Task {
                if newValue {
                    switch await openImmersiveSpace(id: "ImmersiveSpace") {
                    case .opened:
                        immersiveSpaceIsShown = true
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        immersiveSpaceIsShown = false
                        showImmersiveSpace = false
                    }
                } else if immersiveSpaceIsShown {
                    await dismissImmersiveSpace()
                    immersiveSpaceIsShown = false
                }
            }
        }
        .task {
            // 非同期のセッション監視。新しいセッションが見つかるたびにsessionを受け取る
            for await session in SampleActivity.sessions() {
                // セッションの設定を行う
                await manager.configureGroupSession(session: session)
            }
        }
    }
}

#Preview() {
    ContentView(manager: GroupActivityManager())
}
