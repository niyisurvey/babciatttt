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
    private let modelContainer: ModelContainer?
    
    /// Error if model container failed to initialize
    private let initError: Error?
    
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
            initError = nil
            
            // Note: iOS 26+ automatically applies Liquid Glass to standard components.
            // No custom appearance configuration needed - system handles it.
        } catch {
            modelContainer = nil
            initError = error
        }
    }
    
    // MARK: - Body
    
    public var body: some View {
        if let modelContainer = modelContainer {
            LaunchView()
                .environment(\.appDependencies, dependencies)
                .modelContainer(modelContainer)
                .preferredColorScheme(appTheme.colorScheme)
        } else {
            DatabaseErrorView(error: initError)
        }
    }
}

/// Error view shown when SwiftData fails to initialize
private struct DatabaseErrorView: View {
    let error: Error?
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("Unable to Load Data")
                .font(.title.bold())
            
            Text("The app couldn't initialize its database. Try restarting the app or reinstalling if the problem persists.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            if let error = error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal)
            }
        }
        .padding()
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
