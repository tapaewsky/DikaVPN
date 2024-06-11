//
//  ErrorCode.swift
//  GoodVPN
//
//  Created by Said Tapaev on 30.05.2024.
//

import Foundation
public enum ErrorCode: Int {
    
    case noError = 0
    case undefined = 1
    case vpnPermissionNotGranted = 2
    case invalidServerCredentials = 3
    case udpRelayNotEnabled = 4
    case serverUnreachable = 5
    case vpnStartFailure = 6
    case illegalServerConfiguration = 7
    case shadowsocksStartFailure = 8
    case configureSystemProxyFailure = 9
    case noAdminPermissions = 10
    case unsupportedRoutingTable = 11
    case systemMisconfigured = 12
    
    var description: String {
        switch self {
        case .noError:
            return "No Error"
        case .undefined:
            return "Undefined"
        case .vpnPermissionNotGranted:
            return "VPN permissions not granted"
        case .invalidServerCredentials:
            return "Invalid server credentials"
        case .udpRelayNotEnabled:
            return "UDP Relay not enabled"
        case .serverUnreachable:
            return "Server unreachable"
        case .vpnStartFailure:
            return "VPN start failure"
        case .illegalServerConfiguration:
            return "Illegal server configuration"
        case .shadowsocksStartFailure:
            return "Shadowsocks start failure"
        case .configureSystemProxyFailure:
            return "Configure system proxy fauilure"
        case .noAdminPermissions:
            return "No admin permissions"
        case .unsupportedRoutingTable:
            return "Unsupported routing table"
        case .systemMisconfigured:
            return "System misconfigured"
        }
    }
    
}
