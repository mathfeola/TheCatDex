//
//  TheCatDexApp.swift
//  TheCatDex
//
//  Created by Matheus Feola on 01/03/2025.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@main
struct TheCatDexApp: App {
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
      }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: TheCatDexApp.store)
        }
//        .modelContainer(for: [CatBreed.self])
        .modelContainer(SwiftDataModelConfigurationProvider.shared.container)
    }
}

public class SwiftDataModelConfigurationProvider {
    // Singleton instance for configuration
    public static let shared = SwiftDataModelConfigurationProvider(isStoredInMemoryOnly: false, autosaveEnabled: true)
    
    // Properties to manage configuration options
    private var isStoredInMemoryOnly: Bool
    private var autosaveEnabled: Bool
    
    // Private initializer to enforce singleton pattern
    private init(isStoredInMemoryOnly: Bool, autosaveEnabled: Bool) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        self.autosaveEnabled = autosaveEnabled
    }
    
    // Lazy initialization of ModelContainer
    @MainActor
    public lazy var container: ModelContainer = {
        // Define schema and configuration
        let schema = Schema(
            [
                CatBreed.self
            ]
        )
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
        
        // Create ModelContainer with schema and configuration
        let container = try! ModelContainer(for: schema, configurations: [configuration])
        container.mainContext.autosaveEnabled = autosaveEnabled
        return container
    }()
}

extension DependencyValues {
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue }
    }
}

struct Database {
    var context: () throws -> ModelContext
}

extension Database: DependencyKey {
    @MainActor
    public static let liveValue = Self(
        context: { appContext }
    )
}

@MainActor
let appContext: ModelContext = {
    let container = SwiftDataModelConfigurationProvider.shared.container
    let context = ModelContext(container)
    return context
}()

public extension DependencyValues {
    var catBreedDatabase: CatBreedDatabase {
        get { self[CatBreedDatabase.self] }
        set { self[CatBreedDatabase.self] = newValue }
    }
}

public struct CatBreedDatabase {
    public var fetchAll: @Sendable () throws -> [CatBreed]
    public var fetch: @Sendable (FetchDescriptor<CatBreed>) throws -> [CatBreed]
    public var fetchCount: @Sendable (FetchDescriptor<CatBreed>) throws -> Int
    public var add: @Sendable (CatBreed) throws -> Void
    public var delete: @Sendable (CatBreed) throws -> Void
    public var save: @Sendable () throws -> Void
    
    enum CatBreedDatabaseError: Error {
        case add
        case delete
        case save
    }
}

extension CatBreedDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            let descriptor = FetchDescriptor<CatBreed>()
            return try context.fetch(descriptor)  // ✅ Fetch all breeds
        },
        fetch: { descriptor in
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            return try context.fetch(descriptor)  // ✅ Fetch with a descriptor
        },
        fetchCount: { descriptor in
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            return try context.fetch(descriptor).count  // ✅ Get the count
        },
        add: { model in
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            context.insert(model)  // ✅ Insert into SwiftData
            try context.save()  // ✅ Save changes
        },
        delete: { model in
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            context.delete(model)  // ✅ Remove from SwiftData
            try context.save()  // ✅ Save changes
        },
        save: {
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            try context.save()  // ✅ Ensure manual saving
        }
    )
}
