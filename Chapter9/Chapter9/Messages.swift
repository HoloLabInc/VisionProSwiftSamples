//
//  Messages.swift
//  Chapter9
//
//  Created by hiromu on 2024/08/07.
//

import SwiftUI

struct EmojiMessage: Codable {
    let emoji: Emoji
}

struct PoseMessage: Codable {
    let pose: Pose3D
}
