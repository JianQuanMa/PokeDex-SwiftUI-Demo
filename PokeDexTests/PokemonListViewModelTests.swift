import Testing
import Foundation
@testable import PokeDex

@MainActor
struct PokemonListViewModelTests {
    @Test func loadInitial_populatesFirstPageOfResults() async {
        let repository = MockPokemonRepository()
        repository.namesResult = .success(Self.makeSummaries(count: 50))
        let viewModel = PokemonListViewModel(repository: repository, favoritesStore: MockFavoritesStore())

        await viewModel.loadInitial()

        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.visiblePokemons.count == 30)
        #expect(viewModel.visiblePokemons.first?.id == 1)
    }

    @Test func loadInitial_setsErrorStateOnFailure() async {
        let repository = MockPokemonRepository()
        repository.namesResult = .failure(NetworkError.httpError(statusCode: 500))
        let viewModel = PokemonListViewModel(repository: repository, favoritesStore: MockFavoritesStore())

        await viewModel.loadInitial()

        guard case .error = viewModel.viewState else {
            Issue.record("Expected error state")
            return
        }
    }

    @Test func loadMoreIfNeeded_appendsNextPageNearEndOfList() async {
        let repository = MockPokemonRepository()
        repository.namesResult = .success(Self.makeSummaries(count: 50))
        let viewModel = PokemonListViewModel(repository: repository, favoritesStore: MockFavoritesStore())
        await viewModel.loadInitial()

        let triggerItem = viewModel.visiblePokemons[viewModel.visiblePokemons.count - 1]
        viewModel.loadMoreIfNeeded(currentItem: triggerItem)

        #expect(viewModel.visiblePokemons.count == 50)
    }

    @Test func search_filtersCachedResultsByName() async throws {
        let repository = MockPokemonRepository()
        repository.namesResult = .success([
            PokemonSummary(id: 1, name: "bulbasaur"),
            PokemonSummary(id: 4, name: "charmander"),
            PokemonSummary(id: 7, name: "squirtle")
        ])
        let viewModel = PokemonListViewModel(repository: repository, favoritesStore: MockFavoritesStore())
        await viewModel.loadInitial()

        viewModel.searchText = "char"
        try await Task.sleep(for: .milliseconds(400))

        #expect(viewModel.visiblePokemons.map(\.name) == ["charmander"])
    }

    @Test func toggleFavorite_delegatesToFavoritesStore() async {
        let repository = MockPokemonRepository()
        repository.namesResult = .success(Self.makeSummaries(count: 1))
        let favoritesStore = MockFavoritesStore()
        let viewModel = PokemonListViewModel(repository: repository, favoritesStore: favoritesStore)
        await viewModel.loadInitial()

        let pokemon = viewModel.visiblePokemons[0]
        viewModel.toggleFavorite(pokemon)

        #expect(favoritesStore.toggledIDs == [pokemon.id])
    }

    private static func makeSummaries(count: Int) -> [PokemonSummary] {
        (1...count).map { PokemonSummary(id: $0, name: "pokemon-\($0)") }
    }
}
