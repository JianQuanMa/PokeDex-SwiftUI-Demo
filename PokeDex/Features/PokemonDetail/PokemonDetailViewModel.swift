import Foundation
import Observation

@MainActor
@Observable
final class PokemonDetailViewModel {
    enum ViewState: Equatable {
        case loading
        case loaded(PokemonDetail)
        case error(String)
    }

    private(set) var viewState: ViewState = .loading
    let summary: PokemonSummary

    private let repository: PokemonRepositoryProtocol
    private let favoritesStore: FavoritesStoring

    init(summary: PokemonSummary, repository: PokemonRepositoryProtocol, favoritesStore: FavoritesStoring) {
        self.summary = summary
        self.repository = repository
        self.favoritesStore = favoritesStore
    }

    var isFavorite: Bool {
        favoritesStore.isFavorite(id: summary.id)
    }

    func toggleFavorite() {
        favoritesStore.toggleFavorite(id: summary.id, name: summary.name)
    }

    func load() async {
        viewState = .loading
        do {
            let detail = try await repository.fetchPokemonDetail(id: summary.id)
            viewState = .loaded(detail)
        } catch {
            let message = (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
            viewState = .error(message)
        }
    }
}
