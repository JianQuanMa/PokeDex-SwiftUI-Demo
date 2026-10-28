import Testing
@testable import PokeDex

@MainActor
struct FavoritesListViewModelTests {
    @Test func favorites_mirrorsFavoritesStore() {
        let favoritesStore = MockFavoritesStore()
        favoritesStore.toggleFavorite(id: 1, name: "bulbasaur")
        favoritesStore.toggleFavorite(id: 4, name: "charmander")
        let viewModel = FavoritesListViewModel(favoritesStore: favoritesStore)

        #expect(viewModel.favorites.map(\.id) == [1, 4])
        #expect(viewModel.isFavorite(PokemonSummary(id: 1, name: "bulbasaur")))
    }

    @Test func removeFavorite_delegatesToFavoritesStore() {
        let favoritesStore = MockFavoritesStore()
        favoritesStore.toggleFavorite(id: 1, name: "bulbasaur")
        let viewModel = FavoritesListViewModel(favoritesStore: favoritesStore)

        viewModel.removeFavorite(PokemonSummary(id: 1, name: "bulbasaur"))

        #expect(viewModel.favorites.isEmpty)
        #expect(favoritesStore.toggledIDs == [1, 1])
    }
}
