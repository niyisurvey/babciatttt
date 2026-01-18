//
//  AppExitHelper.swift
//  BabciaTobiasz
//

import Foundation

#if os(iOS)
import UIKit
#endif

enum AppExitHelper {
    static func requestExit() {
        #if os(iOS)
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        #endif
    }
}
