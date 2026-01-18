//
//  CameraQuickAddSheet.swift
//  BabciaTobiasz
//

import SwiftUI

struct CameraQuickAddSheet: View {
    let manager: StreamingCameraManager
    let discovery: StreamingCameraDiscoveryResult

    var body: some View {
        NavigationStack {
            switch discovery.kind {
            case .rtsp:
                RTSPQuickAddView(manager: manager, discovery: discovery)
            case .tapo:
                TapoQuickAddView(manager: manager, discovery: discovery)
            case .homeAssistant:
                HomeAssistantQuickAddView(manager: manager, discovery: discovery)
            }
        }
    }
}
