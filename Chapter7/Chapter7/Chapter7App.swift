//
//  Chapter7App.swift
//  Chapter7
//
//  Created by 上山晃弘 on 2024/05/01.
//

import SwiftUI

@main
struct Chapter7App: App {
    var body: some Scene {
        WindowGroup(id: "Window") {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
