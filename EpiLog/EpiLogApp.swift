//
//  EpiLogApp.swift
//  EpiLog
//
//  Created by Martina Kolajová on 01.12.2025.
//

import SwiftUI

import TalsecRuntime

@main
struct EpiLogApp: App {
    init() {
        let config = TalsecConfig(
            appBundleIds: ["com.kolajova.EpiLog"],
            appTeamId: "TVUJ_TEAM_ID",
            watcherMailAddress: "tvuj@email.com",
            isProd: false
        )
        Talsec.start(config: config)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension SecurityThreatCenter: @retroactive SecurityThreatHandler {
    public func threatDetected(_ securityThreat: SecurityThreat) {
        print("⚠️ Threat detected: \(securityThreat.rawValue)")
        
        switch securityThreat {
        case .simulator:
            print("→ Running on simulator")
        case .debugger:
            print("→ Debugger attached")
        case .missingSecureEnclave:
            print("→ No Secure Enclave (simulator)")
        default:
            print("→ Other threat: \(securityThreat)")
        }
    }
}

//@main
//struct EpiLogApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}
//
