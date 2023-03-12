//
//  SocialMediaSwiftUIApp.swift
//  SocialMediaSwiftUI
//
//  Created by Yasin Erdemli on 10.03.2023.
//

import SwiftUI
import Firebase

@main
struct SocialMediaSwiftUIApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
