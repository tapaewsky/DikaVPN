//
//  VPNManager.swift
//  DikaVPN
//
//  Created by Said Tapaev on 30.05.2024.
//



import Foundation
import NetworkExtension
import CocoaLumberjackSwift

protocol OutlineManagerProtocol {
    func disconnect() async
    func connect(_ config: [String: NSObject]?) async throws
    func isConnected() -> Bool
}

enum Constants {
    static let outlineConfig: [String: NSObject]? = {
        return [
            "password": "TFDoXlPCA6BVjyN6uIIXej" as NSObject,
            "host": "194.164.35.150" as NSObject,
            "port":  27288 as NSNumber,
            "method": "chacha20-ietf-poly1305" as NSObject,
        ]
    }()

    
    static let username = "DikaVPN"
    static let outlineBundleId = "Tapg1er.DikaVPN.OutlineVPN"
}

@objcMembers
class OutlineManager: NSObject, OutlineManagerProtocol {
    
    typealias VPNStatusObserver = (NEVPNStatus, String) -> Void
    
    private enum Action {
        static let start = "start"
        static let restart = "restart"
        static let stop = "stop"
        static let getTunnelId = "getTunnelId"
    }
    
    private enum MessageKey {
        static let action = "action"
        static let tunnelId = "tunnelId"
        static let config = "config"
        static let errorCode = "errorCode"
        static let host = "host"
        static let port = "port"
        static let isOnDemand = "is-on-demand"
    }
    
    private var providerManager: NETunnelProviderManager!
    private var activeTunnelId: String?
    private var vpnStatusObserver: VPNStatusObserver?
    
    init(providerManager: NETunnelProviderManager! = nil) {
        super.init()
        Task { await loadProviderManager() }
    }
    
    func connect(_ config: [String: NSObject]?) async throws {
        if providerManager == nil {
            await loadProviderManager()
        }
        await setupVPN()
        do {
            DDLogInfo("Starting VPN connection...", level: .info)
            try providerManager.connection.startVPNTunnel(options: config)
        } catch {
            DDLogError("VPN Connection error: \(error.localizedDescription)", level: .error)
            throw error
        }
    }
    
    func disconnect() async {
        DDLogInfo("Disconnecting tunnel", level: .info)
        if providerManager == nil {
            await loadProviderManager()
        }
        providerManager.connection.stopVPNTunnel()
    }
    
    func isConnected() -> Bool {
        let vpnStatus = providerManager?.connection.status
        return vpnStatus == .connected || vpnStatus == .connecting || vpnStatus == .reasserting
    }
    
    private func loadProviderManager() async {
        DDLogDebug("Loading NETunnelProviderManagers", level: .debug)
        do {
            let managers = try await NETunnelProviderManager.loadAllFromPreferences()
            DDLogDebug("NETunnelProviderManager Managers loaded", level: .debug)
            providerManager = managers.first ?? .init()
        } catch {
            providerManager = .init()
            DDLogError("NETunnelProviderManagers not found, ERROR: \(error.localizedDescription)", level: .error)
        }
    }
    
    private func setupVPN() async {
        DDLogInfo("Creating tunnel", level: .info)
        do {
            try await providerManager.loadFromPreferences()
            
            providerManager.protocolConfiguration = getTunnelProtocol()
            providerManager.localizedDescription = Constants.username
            providerManager.isEnabled = true
            
            try await providerManager.saveToPreferences()
            observeVPNStatus(providerManager)
            NotificationCenter.default.post(name: .NEVPNConfigurationChange, object: nil)
            try await providerManager.loadFromPreferences()
            
            DDLogInfo("VPN setup completed successfully", level: .info)
        } catch {
            DDLogError("Tunnel creation error: \(error.localizedDescription)", level: .error)
        }
    }

    
    private func getTunnelProtocol() -> NETunnelProviderProtocol {
        let tunnelProtocol = NETunnelProviderProtocol()
        tunnelProtocol.providerBundleIdentifier = Constants.outlineBundleId 
        tunnelProtocol.includeAllNetworks = true
        tunnelProtocol.serverAddress = Constants.username
        tunnelProtocol.disconnectOnSleep = false
        return tunnelProtocol
    }
    
    private func retrieveActiveTunnelId() async {
        if providerManager == nil {
            return
        }
        let response = await sendVpnExtensionMessage([MessageKey.action: Action.getTunnelId])
        guard response != nil else {
            return DDLogError("Failed to retrieve the active tunnel ID")
        }
        guard let activeTunnelId = response?[MessageKey.tunnelId] as? String else {
            return DDLogError("Failed to retrieve the active tunnel ID")
        }
        DDLogInfo("Got active tunnel ID: \(activeTunnelId)")
        self.activeTunnelId = activeTunnelId
        self.vpnStatusObserver?(.connected, self.activeTunnelId!)
    }
    
    private func observeVPNStatus(_ manager: NETunnelProviderManager) {
        DDLogInfo("Start observing VPN status", level: .info)
        NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange,
                                                  object: manager.connection)
        NotificationCenter.default.addObserver(self, selector: #selector(self.vpnStatusChanged),
                                               name: .NEVPNStatusDidChange, object: manager.connection)
    }

    @objc private func vpnStatusChanged() {
        if let vpnStatus = providerManager?.connection.status {
            if let tunnelId = activeTunnelId {
                if (vpnStatus == .disconnected) {
                    activeTunnelId = nil
                }
                vpnStatusObserver?(vpnStatus, tunnelId)
            } else if (vpnStatus == .connected) {
                // The VPN was connected from the settings app while the UI was in the background.
                // Retrieve the tunnel ID to update the UI.
                Task { await retrieveActiveTunnelId() }
            }
        }
    }
    
    private func sendVpnExtensionMessage(_ message: [String: Any]) async -> [String: Any]? {
        if providerManager == nil {
            DDLogError("Cannot set an extension callback without a tunnel manager", level: .error)
            return nil
        }
        var data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: message)
        } catch {
            DDLogError("Failed to serialize message to VpnExtension as JSON", level: .error)
            return nil
        }
        
        let handler: (Data?) -> Void = { data in
            if let responseData = data {
                do {
                    if let response = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                        Task {
                            return response
                        }
                        DDLogInfo("Received extension message: \(String(describing: response))")
                    }
                } catch {
                    DDLogError("Failed to deserialize the VpnExtension response", level: .warning)
                }
            } else {
                DDLogError("ResponseData is Empty", level: .warning)
            }
        }
        
        let session: NETunnelProviderSession = providerManager.connection as! NETunnelProviderSession
        do {
            try session.sendProviderMessage(data, responseHandler: handler)
        } catch {
            DDLogError("Failed to send message to VpnExtension", level: .warning)
            return nil
        }
        return nil
    }
}
