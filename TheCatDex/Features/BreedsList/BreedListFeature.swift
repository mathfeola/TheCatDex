//
//  BreedListFeature.swift
//  TheCatDex
//
//  Created by Matheus Feola on 02/03/2025.
//

import SwiftUI
import ComposableArchitecture
import SwiftData

@Reducer
struct BreedListFeature {
    
    enum FeatureErrorMessages: String {
        case decodingError = "🐛 Decoding error: "
        case networkError = "🌐 Network error: "
        case unknownError = "❌ Unknown error: "
    }
    
    @ObservableState
    struct State: Equatable {
        var breeds: [CatBreed] = []
        var isLoading = false
        var selectedBreed: BreedDetailFeature.State?
        var shouldOpenDetail = false
        var shouldShowErrorState = false
        var currentErrorMessage = String()
        var currentPage = 0
        var isFetchingMore = false
        var favouriteBreedIDs: Set<String> = []
        var filterText: String = ""
        var filteredBreeds: [CatBreed] = []
        
        func fetchCatBreeds() -> [CatBreed] {
            @Dependency(\.catBreedDatabase.fetchAll) var fetchAll
            do {
                return try fetchAll()  // ✅ Fetch all stored breeds
            } catch {
                print("❌ Error fetching breeds from SwiftData: \(error)")
                return []  // ✅ Return empty if an error occurs
            }
        }
    }
    
    enum Action {
        case fetchBreedList
        case breedListResponse([CatBreed])
        case filter(String)
        case breedSelected(CatBreed)
        case closeDetailModal
        case displayError(String)
        case fetchMoreBreeds
        case updateFavourites([CatBreed])
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBreedList:
                state.currentPage = 0
                state.isFetchingMore = true
                return .run { send in
                    do {
                        let breeds = try await CatAPI.fetchCatBreeds(page: 0).execute() as? [CatBreed]
                        await send(.breedListResponse(breeds ?? []))
                    } catch FetchError.decodingError(let decodingError) {
                        await send(.displayError(FeatureErrorMessages.decodingError.rawValue + decodingError.localizedDescription))
                    } catch FetchError.networkError(let networkError) {
                        await send(.displayError(FeatureErrorMessages.networkError.rawValue + networkError.localizedDescription))
                    } catch {
                        await send(.displayError(FeatureErrorMessages.unknownError.rawValue + error.localizedDescription))
                    }
                }
            case let .breedListResponse(breeds):
                state.breeds += breeds
                state.currentPage += 1
                state.isFetchingMore = false
                state.currentErrorMessage = String()
                state.shouldShowErrorState = false
                return .none
            case let .filter(query):
                state.filterText = query
                if query.isEmpty {
                    state.filteredBreeds = state.breeds
                } else {
                    state.filteredBreeds = state.breeds.filter { breed in
                        if let breedName = breed.name {
                            return breedName.lowercased().contains(query.lowercased())
                        }
                        return false
                    }
                }
                
                return .none
            case let .breedSelected(breed):
                state.selectedBreed = BreedDetailFeature.State(breed: breed)
                state.shouldOpenDetail = true
                return .none
            case .closeDetailModal:
                state.shouldOpenDetail = false
                return .none
            case let .displayError(message):
                state.currentErrorMessage = message
                state.shouldShowErrorState = true
                return .none
            case .fetchMoreBreeds:
                guard !state.isFetchingMore else { return .none }
                state.isFetchingMore = true
                return .run { [currentPage = state.currentPage] send in
                    let moreBreeds = try await CatAPI.fetchCatBreeds(page: currentPage).execute() as? [CatBreed]
                    await send(.breedListResponse(moreBreeds ?? []))
                }
            case let .updateFavourites(breeds):
                state.favouriteBreedIDs = Set(breeds.map { $0.id })
                return .none
            }
        }
    }
}

struct BreedsListView: View {
    let navigationBarTitle = "Cat breeds"
    let emptyListSymbolName = "exclamationmark.arrow.trianglehead.2.clockwise.rotate.90"
    let store: StoreOf<BreedListFeature>
    @Environment(\.modelContext) var modelContext
    @Query var currentFavouritesBreeds: [CatBreed]
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                TextField("Search breeds...", text: viewStore.binding(
                    get: \.filterText,
                    send: { .filter($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                if !viewStore.filterText.isEmpty {
                    filteredBreedsList
                } else {
                    catBreedList
                }
                
                if viewStore.isFetchingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .foregroundStyle(Color("lightCoral"))
                                .padding()
                            Spacer()
                        }
                    }
            }
            .task {
                if viewStore.breeds.isEmpty {
                    viewStore.send(.fetchBreedList)
                }
            }
            .onAppear {
                viewStore.send(.updateFavourites(currentFavouritesBreeds))
            }
            .sheet(
                isPresented: Binding(
                    get: { viewStore.shouldOpenDetail },
                    set: { isPresented in
                        if !isPresented {
                            viewStore.send(.closeDetailModal)
                        }
                    }
                )
            ) {
                breedDetailSheet
            }
        }
    }
    
    var breedDetailSheet: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if let selectedBreedState = viewStore.selectedBreed {
                BreedDetailSheet(store: Store(
                    initialState: BreedDetailFeature.State(breed: selectedBreedState.breed),
                    reducer: { BreedDetailFeature() }
                ))
            }
        }
    }
    
    var emptyStateView: some View {
        VStack {
            Image(systemName: "cat.fill")
                .resizable()
                .frame(width: 140, height: 100)
                .padding()
            Text("No catties match your search 🙀")
                .font(.title2)
                .fontWeight(.bold)
                .padding()
        }
    }
    
    var errorStateView: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            if viewStore.shouldShowErrorState {
                VStack {
                    Image(systemName: emptyListSymbolName)
                        .resizable()
                        .foregroundStyle(.pink)
                        .frame(width: 160, height: 120)
                        .padding()
                    Text(viewStore.currentErrorMessage)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.pink)
                        .padding()
                }
            }
        }
    }
    
    var catBreedList: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.breeds, id: \.id) { breed in
                CatBreedItemList(breed: breed, isFavourite: viewStore.favouriteBreedIDs.contains(breed.id))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        viewStore.send(.breedSelected(breed))
                    }
                    .onAppear {
                        if breed == viewStore.breeds.last {
                            viewStore.send(.fetchMoreBreeds)
                        }
                    }
            }
            .overlay {
                errorStateView
            }
            .navigationBarTitle(navigationBarTitle)
        }
    }
    
    var filteredBreedsList: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List(viewStore.filteredBreeds, id: \.id) { breed in
                CatBreedItemList(breed: breed, isFavourite: viewStore.favouriteBreedIDs.contains(breed.id))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        viewStore.send(.breedSelected(breed))
                    }
                    .onAppear {
                        if breed == viewStore.breeds.last {
                            viewStore.send(.fetchMoreBreeds)
                        }
                    }
            }
            .overlay {
                if viewStore.filteredBreeds.isEmpty && !viewStore.filterText.isEmpty {
                    emptyStateView
                }
            }
            .overlay {
                errorStateView
            }
            .navigationBarTitle(navigationBarTitle)
        }
    }
}

struct CatBreedItemList: View {
    let breed: CatBreed
    let placeholderSymbolName = "cat.circle"
    var isFavourite: Bool
    
    @State private var showingSucessAlert = false
    @State private var showingErrorAlert = false
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        HStack {
            if let breedImage = breed.image,
               let url = URL(string: breedImage.url) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.lightCoral, lineWidth: 2)
                            )
                    case .failure:
                        Image(systemName: placeholderSymbolName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.pink, lineWidth: 2)
                            )
                    case .empty:
                        ProgressView()
                            .frame(width: 40, height: 40)
                    @unknown default:
                        fatalError("Error loading image")
                    }
                }
            }
            Text("\(breed.name ?? "Cat breed name")")
            Spacer()
        }
        .swipeActions {
            Button {
                isFavourite ? removeFromFavourites(breed: breed) : store(breed)
            } label: {
                HStack {
                    Text(isFavourite ? "Remove Favourite" : "Save Favourite")
                        .font(.caption2)
                        .foregroundColor(isFavourite ? .green : .gray)
                }
                .padding()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("lightCoral"), lineWidth: 2)
                )
                .frame(width: 10, height: 10)
                .padding()
            }
        }
        .alert("Updated favourite! 😻", isPresented: $showingSucessAlert) {
            Button("OK", role: .cancel) { }
                .tint(.lightCoral)
        }
        .alert("Error saving your cat breed in device 😿", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
                .tint(.lightCoral)
        }
    }
    
    func store(_ favourite: CatBreed) {
        let existingBreeds = try? modelContext.fetch(FetchDescriptor<CatBreed>())
        if existingBreeds?.contains(where: { $0.id == favourite.id }) == true {
            print("Breed already exists in favourites")
            return
        }
        
        modelContext.insert(favourite)
        
        do {
            try modelContext.save()
            showingSucessAlert = true
        } catch {
            showingErrorAlert = true
        }
    }
    
    private func removeFromFavourites(breed: CatBreed) {
        let descriptor = FetchDescriptor<CatBreed>()
        if let favourites = try? modelContext.fetch(descriptor) {
            if let existingBreed = favourites.first(where: { $0.id == breed.id }) {
                modelContext.delete(existingBreed)
                try? modelContext.save()
            }
        }
    }
}
