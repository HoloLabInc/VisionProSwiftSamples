//
//  Omikuji.swift
//  Chapter3
//
//  Created by 上山晃弘 on 2024/05/01.
//

import Foundation
import SwiftUI

class Omikuji {
    private enum KujiType: String, CaseIterable {
        case 大吉 = "omikuji_box_daikichi"
        case 中吉 = "omikuji_box_chuukichi"
        case 小吉 = "omikuji_box_shoukichi"
        case 吉 = "omikuji_box_kichi"
    }
    
    private var result_: KujiType = .大吉
    
    func select() {
        result_ = KujiType.allCases.randomElement()!
    }
    
    func result() -> String {
        return result_.rawValue
    }
    
    func resultColor() -> Color {
        switch result_ {
        case .大吉:
            return Color.red
        case .中吉:
            return Color.orange
        case .小吉:
            return Color.green
        case .吉:
            return Color.blue
        }
    }
}
