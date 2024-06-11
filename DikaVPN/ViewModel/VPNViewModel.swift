//
//  ViewModel.swift
//  DikaVpn
//
//  Created by Said Tapaev on 08.04.2024.
//

import Foundation
import Combine
import os.log

class VPNViewModel: ObservableObject {
    private let logger = Logger(subsystem: "Tapg1er.DikaVPN", category: "VPNViewModel")
    
    @Published var isVPNEnabled = true
    @Published var sentData: Double = 0.0
    @Published var receivedData: Double = 0.0
    @Published var isTogglingVPN = false
    
    let manager: OutlineManagerProtocol
    
    init() {
        self.manager = OutlineManager()
    }
    
    @MainActor
    func toggleVPN() async {
        
        guard !isTogglingVPN else {
            logger.debug("toggleVPN() is already in progress, skipping this call")
            return
        }
        
        isTogglingVPN = true
        
        do {
            logger.debug("Toggling VPN...")
            if isVPNEnabled {
                logger.debug("Connecting VPN with config: \(String(describing: Constants.outlineConfig))")
                do {
                    try await manager.connect(Constants.outlineConfig)
                    logger.debug("VPN connected successfully")
                    isVPNEnabled = false
                } catch {
                    logger.error("Failed to connect VPN: \(error.localizedDescription, privacy: .public)")
                    print("Failed to connect VPN: \(error.localizedDescription)")
                }
            } else {
                logger.debug("Disconnecting VPN...")
                do {
                    try await manager.disconnect()
                    logger.debug("VPN disconnected successfully")
                    isVPNEnabled = true
                } catch {
                    logger.error("Failed to disconnect VPN: \(error.localizedDescription, privacy: .public)")
                    print("Failed to disconnect VPN: \(error.localizedDescription)")
                }
            }
        } catch {
            logger.error("Failed to toggle VPN: \(error.localizedDescription, privacy: .public)")
            print("Failed to toggle VPN: \(error.localizedDescription)")
        }
        
        isTogglingVPN = false
    }
}
