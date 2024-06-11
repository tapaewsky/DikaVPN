//
//  ViewModelSecont.swift
//  DikaVpn
//
//  Created by Said Tapaev on 08.04.2024.
//

import Foundation
import UIKit

class SecondViewModel: ObservableObject {
    func openTelegram() {
        guard let url = URL(string: "https://t.me/sdtpv") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
