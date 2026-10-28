import Foundation
import SwiftData

/// Composition root. Nothing fancy: plain initializer injection is enough
/// for an object graph this small, so there's no DI framework to learn.
@MainActor
final class AppContainer {
    let apiClient: APIClientProtocol
    let repository: PokemonRepositoryProtocol
    let modelContainer: ModelContainer
    let favoritesStore: FavoritesStore

    init() {
        apiClient = URLSessionAPIClient()
        repository = PokemonRepository(apiClient: apiClient)
        modelContainer = try! ModelContainer(for: FavoritePokemon.self)
        favoritesStore = FavoritesStore(modelContext: modelContainer.mainContext)
    }

    func makeListViewModel() -> PokemonListViewModel {
        PokemonListViewModel(repository: repository, favoritesStore: favoritesStore)
    }

    func makeDetailViewModel(for summary: PokemonSummary) -> PokemonDetailViewModel {
        PokemonDetailViewModel(summary: summary, repository: repository, favoritesStore: favoritesStore)
    }
}
