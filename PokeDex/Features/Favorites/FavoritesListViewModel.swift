import Foundation
import Observation

@MainActor
@Observable
final class FavoritesListViewModel {
    private let favoritesStore: FavoritesStoring

    init(favoritesStore: FavoritesStoring) {
        self.favoritesStore = favoritesStore
    }

    var favorites: [PokemonSummary] {
        favoritesStore.favoritePokemons
    }

    func isFavorite(_ pokemon: PokemonSummary) -> Bool {
        favoritesStore.isFavorite(id: pokemon.id)
    }

    func removeFavorite(_ pokemon: PokemonSummary) {
        favoritesStore.toggleFavorite(id: pokemon.id, name: pokemon.name)
    }
}
