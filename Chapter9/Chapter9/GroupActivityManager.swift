//
//  GroupActivityManager.swift
//  Chapter9
//
//  Created by hiromu on 2024/08/07.
//

import Combine
import GroupActivities
import RealityKit
import SwiftUI

@Observable
class GroupActivityManager {
    // 現在のグループセッションを保持する
    var session: GroupSession<SampleActivity>?
    // メッセージの送受信を行うメッセンジャー
    var messenger: GroupSessionMessenger?
    // 信頼性あるメッセージの送受信を行うメッセンジャー
    var reliableMessenger: GroupSessionMessenger?
    // セッションの状態や参加者の変更を監視するためのサブスクリプションを保持する
    var subscriptions = Set<AnyCancellable>()
    // 実行中のタスクを保持する
    var tasks = Set<Task<Void, Never>>()
    // SharePlayがアクティブかどうかを示すブール値
    var isSharePlaying = false
    // 送受信する絵文字情報を保持する
    var emoji = Emoji.happy
    // 送受信するポーズ(位置、回転）情報を保持する
    var pose = Pose3D()
    // 共有されたイマーシブスペースにいるかどうかを示すブール値
    var isSpatial = false
    // 位置の共有を行うエンティティ
    var entity: ModelEntity?

    // SharePlayセッションを開始する
    func startSession() {
        Task {
            do {
                _ = try await SampleActivity().activate()
            } catch {
                print("Failed to activate SampleActivity: \(error)")
            }
        }
    }

    // セッションの設定を行う
    func configureGroupSession(session: GroupSession<SampleActivity>) async {
        print("New GroupActivities session: \(session)")
        // アプリのアクティブなグループセッションを設定する
        self.session = session

        // 以前のサブスクリプションとタスクを削除する
        subscriptions.removeAll()
        tasks.forEach { $0.cancel() }
        tasks.removeAll()

        // セッションに参加しているデバイスにデータを送受信するメッセンジャーの生成
        messenger = GroupSessionMessenger(session: session, deliveryMode: .unreliable)
        reliableMessenger = GroupSessionMessenger(session: session, deliveryMode: .reliable)

        // セッションが無効になった時の処理
        setupStateSubscription(for: session)
        // 参加者リストの変更処理
        setupParticipantsSubscription(for: session)
        // 絵文字メッセージを受信するための処理
        setupEmojiMessageHandler()
        // ポーズメッセージを受信するための処理
        setupPoseMessageHandler()
        // アクティブなセッションに関連付けられたシステムコーディネータの設定
        await setCoordinatorConfiguration(session: session)

        // セッションに参加する
        session.join()
        isSharePlaying = true
    }

    // セッションの状態を監視し、
    // セッションが無効になった場合に終了処理を行うサブスクリプションを設定する
    private func setupStateSubscription(for session: GroupSession<SampleActivity>) {
        session.$state
            .sink { [weak self] state in
                if case .invalidated = state {
                    self?.endSession()
                }
            }
            .store(in: &subscriptions)
    }

    // 参加者の変更を監視し、新しい参加者に現在の情報を送信するサブスクリプションを設定する
    private func setupParticipantsSubscription(for session: GroupSession<SampleActivity>) {
        session.$activeParticipants
            .sink { [weak self] activeParticipants in
                guard let self else { return }
                let newParticipants = activeParticipants.subtracting(session.activeParticipants)
                print("newParticipants: \(newParticipants)")
                // 絵文字の同期
                self.sendEmojiMessage(message: EmojiMessage(emoji: self.emoji))
                // エンティティの位置、回転の同期
                self.sendPoseMessage(message: PoseMessage(pose: pose))
            }
            .store(in: &subscriptions)
    }

    // 絵文字メッセージを受信するためのハンドラを設定する
    private func setupEmojiMessageHandler() {
        guard let reliableMessenger else { return }

        let emojiTask = Task {
            for await (message, sender) in reliableMessenger.messages(of: EmojiMessage.self) {
                print("sender: \(sender), message: \(message)")
                handleEmojiMessage(message: message)
            }
        }
        tasks.insert(emojiTask)
    }

    // ポーズメッセージを受信するためのハンドラを設定する
    private func setupPoseMessageHandler() {
        guard let messenger else { return }

        let poseTask = Task {
            for await (message, _) in messenger.messages(of: PoseMessage.self) {
                handlePoseMessage(message: message)
            }
        }
        tasks.insert(poseTask)
    }

    // システムコーディネータの設定を行う
    private func setCoordinatorConfiguration(session: GroupSession<SampleActivity>) async {
        // アクティブなセッションに関連付けられたシステムコーディネータを取得する
        if let coordinator = await session.systemCoordinator {
            // FaceTime通話での空間ペルソナの作成と配置に関するアプリの設定
            var config = SystemCoordinator.Configuration()
            // 参加者がコンテンツを前にして横並びになる配置
            config.spatialTemplatePreference = .sideBySide
            // イマーシブスペースで空間ペルソナを表示できるようにする
            config.supportsGroupImmersiveSpace = true
            // 作成した設定をコーディネータに適用する
            coordinator.configuration = config

            // 参加者の状態を監視し、isSpatialプロパティを更新する非同期タスクを作成
            Task.detached { @MainActor in
                // ローカル参加者の状態を非同期に監視する
                for await state in coordinator.localParticipantStates {
                    // 共有されたイマーシブスペースにいるかどうかを示すブール値
                    if state.isSpatial {
                        self.isSpatial = true
                    } else {
                        self.isSpatial = false
                    }
                }
            }
        }
    }

    // 絵文字メッセージの処理を行う
    func handleEmojiMessage(message: EmojiMessage) {
        print("emoji: \(message.emoji)")
        emoji = message.emoji
    }

    // 絵文字メッセージを送信する
    func sendEmojiMessage(message: EmojiMessage) {
        if let session, let reliableMessenger {
            // 自分以外の参加者
            let everyoneElse = session.activeParticipants.subtracting([session.localParticipant])
            // 絵文字メッセージを自分以外の参加者に送信する
            reliableMessenger.send(message, to: .only(everyoneElse)) { error in
                if let error {
                    print("EmojiMessage failure: \(error)")
                }
            }
        }
    }

    // ポーズメッセージの処理を行う
    func handlePoseMessage(message: PoseMessage) {
        pose = message.pose
    }

    // ポーズメッセージを送信する
    func sendPoseMessage(message: PoseMessage) {
        print("pose: \(message.pose)")
        if let session, let messenger {
            // 自分以外の参加者
            let everyoneElse = session.activeParticipants.subtracting([session.localParticipant])

            if isSpatial {
                // ポーズメッセージを自分以外の参加者に送信する
                messenger.send(message, to: .only(everyoneElse)) { error in
                    if let error {
                        print("PoseMessage failure: \(error)")
                    }
                }
            }
        }
    }

    // SharePlayセッションを終了する
    func endSession() {
        isSharePlaying = false
        isSpatial = false
        messenger = nil
        reliableMessenger = nil
        tasks.forEach { $0.cancel() }
        tasks.removeAll()
        subscriptions.removeAll()
        if session != nil {
            session?.leave()
            session = nil
        }
    }
}
