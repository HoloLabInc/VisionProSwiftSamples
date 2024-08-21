//
//  Chapter5App.swift
//  Chapter5
//
//  Created by hiromu on 2024/08/07.
//

import SwiftUI

@main
struct Chapter5App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }

    init() {
        MoveComponent.registerComponent()
        MoveSystem.registerSystem()
    }
}
