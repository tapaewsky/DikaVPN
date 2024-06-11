//
//  ContentView.swift
//  DikaVpn
//
//  Created by Said Tapaev on 08.04.2024.
//

import SwiftUI



struct ContentView: View {
    @State private var isSignedIn = UserDefaults.standard.bool(forKey: "isSignedIn")

    var body: some View {
        if isSignedIn {
            MainContentView(isSignedIn: $isSignedIn)
        } else {
            SignIn(onSignInSuccess: {
                UserDefaults.standard.set(true, forKey: "isSignedIn")
                isSignedIn = true
            })
        }
    }
}

