//
//  CatBreedDatabase.swift
//  TheCatDex
//
//  Created by Matheus Feola on 05/03/2025.
//

import ComposableArchitecture
import SwiftData

public extension DependencyValues {
    var catBreedDatabase: CatBreedDatabase {
        get { self[CatBreedDatabase.self] }
        set { self[CatBreedDatabase.self] = newValue }
    }
}

public struct CatBreedDatabase {
    var catIsFavourite: (CatBreed) throws -> CatBreed?
    public var fetchAll: @Sendable () throws -> [CatBreed]
    public var add: @Sendable (CatBreed) throws -> Void
    public var delete: @Sendable (CatBreed) throws -> Void
    
    enum CatBreedDatabaseError: Error {
        case add
        case delete
    }
}

extension CatBreedDatabase: DependencyKey {
    public static let liveValue = Self(
        catIsFavourite: { model in
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            var descriptor = FetchDescriptor<CatBreed>()
            let oloco = try context.fetch(descriptor).first
            return oloco
        },
        fetchAll: {
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            let descriptor = FetchDescriptor<CatBreed>()
            return try context.fetch(descriptor)
        },
        add: { model in
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            context.insert(model)
            try context.save()
        },
        delete: { model in
            @Dependency(\.databaseService.context) var contextProvider
            let context = try contextProvider()
            context.delete(model)
            try context.save()
        }
    )
}

public class SwiftDataModelConfigurationProvider {
    public static let shared = SwiftDataModelConfigurationProvider(isStoredInMemoryOnly: false, autosaveEnabled: true)
    
    private var isStoredInMemoryOnly: Bool
    private var autosaveEnabled: Bool
    
    private init(isStoredInMemoryOnly: Bool, autosaveEnabled: Bool) {
        self.isStoredInMemoryOnly = isStoredInMemoryOnly
        self.autosaveEnabled = autosaveEnabled
    }
    
    @MainActor
    public lazy var container: ModelContainer = {
        let schema = Schema([CatBreed.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: isStoredInMemoryOnly)
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
