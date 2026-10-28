import Testing
@testable import PokeDex

@MainActor
struct PokemonDetailViewModelTests {
    @Test func load_populatesDetailOnSuccess() async {
        let repository = MockPokemonRepository()
        repository.detailResult = .success(Self.makeDetail())
        let viewModel = PokemonDetailViewModel(
            summary: PokemonSummary(id: 1, name: "bulbasaur"),
            repository: repository,
            favoritesStore: MockFavoritesStore()
        )

        await viewModel.load()

        guard case .loaded(let detail) = viewModel.viewState else {
            Issue.record("Expected loaded state")
            return
        }
        #expect(detail.name == "bulbasaur")
        #expect(repository.detailRequests == [1])
    }

    @Test func load_setsErrorStateOnFailure() async {
        let repository = MockPokemonRepository()
        repository.detailResult = .failure(NetworkError.httpError(statusCode: 404))
        let viewModel = PokemonDetailViewModel(
            summary: PokemonSummary(id: 1, name: "bulbasaur"),
            repository: repository,
            favoritesStore: MockFavoritesStore()
        )

        await viewModel.load()

        guard case .error = viewModel.viewState else {
            Issue.record("Expected error state")
            return
        }
    }

    @Test func toggleFavorite_delegatesToFavoritesStore() {
        let favoritesStore = MockFavoritesStore()
        let viewModel = PokemonDetailViewModel(
            summary: PokemonSummary(id: 1, name: "bulbasaur"),
            repository: MockPokemonRepository(),
            favoritesStore: favoritesStore
        )

        viewModel.toggleFavorite()

        #expect(favoritesStore.toggledIDs == [1])
    }

    private static func makeDetail() -> PokemonDetail {
        PokemonDetail(
            id: 1,
            name: "bulbasaur",
            heightDecimeters: 7,
            weightHectograms: 69,
            types: ["grass", "poison"],
            abilities: ["overgrow"],
            stats: [PokemonStat(name: "hp", value: 45)],
            artworkURL: nil
        )
    }
}
