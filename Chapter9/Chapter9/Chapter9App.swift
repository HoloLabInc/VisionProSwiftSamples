//
//  Chapter9App.swift
//  Chapter9
//
//  Created by hiromu on 2024/08/07.
//

import SwiftUI

@main
struct Chapter9App: App {
    let manager = GroupActivityManager()

    var body: some Scene {
        WindowGroup {
            ContentView(manager: manager)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView(manager: manager)
        }
    }
}
