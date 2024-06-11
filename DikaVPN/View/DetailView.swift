//
//  DetailView.swift
//  DikaVpn
//
//  Created by Said Tapaev on 08.04.2024.
//

import SwiftUI

struct DetailView: View {
    var title: String
    var content: String
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(content)
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}
