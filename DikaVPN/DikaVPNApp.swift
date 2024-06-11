//
//  DikaVPNApp.swift
//  DikaVPN
//
//  Created by Said Tapaev on 01.06.2024.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct DikaVPNApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    


  var body: some Scene {
    WindowGroup {
      NavigationView {
        ContentView()
              .preferredColorScheme(.dark)
      }
    }
  }
}
