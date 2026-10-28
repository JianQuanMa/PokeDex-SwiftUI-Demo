import Foundation
import Observation

@MainActor
@Observable
final class PokemonListViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    private(set) var viewState: ViewState = .idle
    private(set) var visiblePokemons: [PokemonSummary] = []

    var searchText: String = "" {
        didSet {
            guard searchText != oldValue else { return }
            scheduleSearch()
        }
    }

    private let repository: PokemonRepositoryProtocol
    private let favoritesStore: FavoritesStoring

    private var allPokemons: [PokemonSummary] = []
    private var filteredPokemons: [PokemonSummary] = []
    private var displayedCount = 0
    private let pageSize = 30
    private var searchTask: Task<Void, Never>?

    init(repository: PokemonRepositoryProtocol, favoritesStore: FavoritesStoring) {
        self.repository = repository
        self.favoritesStore = favoritesStore
    }

    func isFavorite(_ pokemon: PokemonSummary) -> Bool {
        favoritesStore.isFavorite(id: pokemon.id)
    }

    func toggleFavorite(_ pokemon: PokemonSummary) {
        favoritesStore.toggleFavorite(id: pokemon.id, name: pokemon.name)
    }

    func loadInitial() async {
        guard viewState == .idle || isError else { return }
        viewState = .loading
        do {
            allPokemons = try await repository.fetchAllPokemonNames()
            filteredPokemons = allPokemons
            displayedCount = 0
            appendNextPage()
            viewState = .loaded
        } catch {
            viewState = .error(Self.message(for: error))
        }
    }

    func refresh() async {
        viewState = .idle
        await loadInitial()
    }

    /// Called from each row's `onAppear`; once the user scrolls within
    /// a handful of items of the end of the currently visible slice,
    /// reveal the next page from the already-fetched, already-filtered list.
    func loadMoreIfNeeded(currentItem: PokemonSummary) {
        guard let index = visiblePokemons.firstIndex(of: currentItem) else { return }
        let thresholdIndex = visiblePokemons.index(
            visiblePokemons.endIndex,
            offsetBy: -5,
            limitedBy: visiblePokemons.startIndex
        ) ?? visiblePokemons.startIndex
        if index >= thresholdIndex {
            appendNextPage()
        }
    }

    private func appendNextPage() {
        guard displayedCount < filteredPokemons.count else { return }
        let nextCount = min(displayedCount + pageSize, filteredPokemons.count)
        visiblePokemons = Array(filteredPokemons[0..<nextCount])
        displayedCount = nextCount
    }

    /// Debounces search input with structured concurrency instead of
    /// Combine: cancel any in-flight wait, sleep, then bail out early via
    /// `Task.isCancelled` if the user kept typing.
    private func scheduleSearch() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            self.applySearch()
        }
    }

    private func applySearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        filteredPokemons = query.isEmpty
            ? allPokemons
            : allPokemons.filter { $0.name.contains(query) }
        displayedCount = 0
        visiblePokemons = []
        appendNextPage()
    }

    private var isError: Bool {
        if case .error = viewState { return true }
        return false
    }

    private static func message(for error: Error) -> String {
        (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
    }
}
