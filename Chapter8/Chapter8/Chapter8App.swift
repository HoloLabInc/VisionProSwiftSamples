//
//  Chapter8App.swift
//  Chapter8
//
//  Created by 上山晃弘 on 2024/05/11.
//

import SwiftUI

@main
struct Chapter8App: App {
    var body: some Scene {
        WindowGroup(id: "Window") {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
