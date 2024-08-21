//
//  AppModel.swift
//  Chapter6
//
//  Created by hiromu on 2024/08/07.
//

import RealityKit
import SwiftUI

@Observable
class AudioInfo {
    var entity: Entity?
    var audio: AudioFileResource?
    var isPlaying: Bool = false
}

@Observable
class AppModel {
    var audioInfo: [AudioInfo] = [.init(), .init(), .init(), .init()]
    var sliderValue: Float = 0.0

    func toggleAudio(info: AudioInfo) {
        guard let entity = info.entity, let audio = info.audio else { return }

        if info.isPlaying {
            entity.stopAllAudio()
        } else {
            entity.playAudio(audio)
        }
        info.isPlaying.toggle()
    }
}
