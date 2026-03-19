//
//  watchmeApp.swift
//  watchme Watch App
//
//  Created by Ray Brennan on 18/03/2026.
//

import SwiftUI

@main
struct watchme_Watch_AppApp: App {
    
    init() {
            // Start WCSession as early as possible
            _ = WatchConnectivityManager.shared
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
