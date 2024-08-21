//
//  Chapter6App.swift
//  Chapter6
//
//  Created by hiromu on 2024/08/07.
//

import SwiftUI

@main
struct Chapter6App: App {
    private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(model)
        }
    }
}
