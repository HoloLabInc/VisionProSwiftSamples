//
//  Chapter4App.swift
//  Chapter4
//
//  Created by hiromu on 2024/08/07.
//

import SwiftUI

@main
struct Chapter4App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.5, height: 0.5, depth: 0.5, in: .meters)
    }
}
