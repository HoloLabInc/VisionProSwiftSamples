//
//  Emoji.swift
//  Chapter9
//
//  Created by hiromu on 2024/08/07.
//

enum Emoji: Codable {
    case happy
    case angry
    case sad
    case laughing

    var symbol: String {
        switch self {
        case .happy:
            return "☺️"
        case .angry:
            return "😠"
        case .sad:
            return "😭"
        case .laughing:
            return "😆"
        }
    }
}
