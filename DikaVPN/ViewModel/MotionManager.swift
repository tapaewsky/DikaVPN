//
//  MotionManager.swift
//  DikaVPN
//
//  Created by Said Tapaev on 02.06.2024.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    @Published var x: Double = 0.0
    @Published var y: Double = 0.0

    init() {
        startMotionUpdates()
    }

    private func startMotionUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
            motionManager.startDeviceMotionUpdates(to: .main) { (motion, error) in
                guard let motion = motion else { return }
                self.x = motion.gravity.x
                self.y = motion.gravity.y
            }
        }
    }

    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

