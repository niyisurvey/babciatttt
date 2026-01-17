//
//  BabciaTobiaszAppView.swift
//  BabciaTobiasz
//
//  Created on 2024-12-30.
//  A modern iOS app combining weather tracking with area management.
//  Built with Swift 6+, SwiftUI, SwiftData, and Apple's Liquid Glass design.
//

import SwiftUI
import SwiftData

/// Root view for the BabciaTobiasz app, hosted by the iOS app target.
public struct BabciaTobiaszAppView: View {
    
    // MARK: - Properties
    
    /// Shared app dependencies container for dependency injection
    @State private var dependencies = AppDependencies()
    
    /// SwiftData model container for persistent storage
    private let modelContainer: ModelContainer
    
    /// App Theme Storage
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    
    // MARK: - Initialization
    
    /// Initializes the app and configures the SwiftData model container.
    /// Sets up persistence for core app models.
    public init() {
        do {
            // Configure the schema with all SwiftData models
            let schema = Schema(SchemaV1.models)
            
            // Create model configuration with CloudKit preparation
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // Ready to switch to .automatic for CloudKit
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            // Note: iOS 26+ automatically applies Liquid Glass to standard components.
            // No custom appearance configuration needed - system handles it.
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Body
    
    public var body: some View {
        LaunchView()
            .environment(\.appDependencies, dependencies)
            .modelContainer(modelContainer)
            .preferredColorScheme(appTheme.colorScheme)
    }
}

extension AppTheme {
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
