import SwiftUI

struct PokemonListView: View {
    @State private var viewModel: PokemonListViewModel
    private let makeDetailViewModel: (PokemonSummary) -> PokemonDetailViewModel

    init(
        viewModel: PokemonListViewModel,
        makeDetailViewModel: @escaping (PokemonSummary) -> PokemonDetailViewModel
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Pokédex")
                .searchable(text: $viewModel.searchText, prompt: "Search Pokémon")
                .task { await viewModel.loadInitial() }
                .refreshable { await viewModel.refresh() }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.viewState {
        case .idle, .loading:
            if viewModel.visiblePokemons.isEmpty {
                ProgressView("Loading Pokémon…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                list
            }
        case .loaded:
            if viewModel.visiblePokemons.isEmpty {
                ContentUnavailableView.search
            } else {
                list
            }
        case .error(let message):
            ContentUnavailableView {
                Label("Couldn't load Pokémon", systemImage: "wifi.slash")
            } description: {
                Text(message)
            } actions: {
                Button("Retry") { Task { await viewModel.loadInitial() } }
            }
        }
    }

    private var list: some View {
        List(viewModel.visiblePokemons) { pokemon in
            NavigationLink(value: pokemon) {
                PokemonRowView(
                    pokemon: pokemon,
                    isFavorite: viewModel.isFavorite(pokemon),
                    onToggleFavorite: { viewModel.toggleFavorite(pokemon) }
                )
            }
            .onAppear { viewModel.loadMoreIfNeeded(currentItem: pokemon) }
        }
        .navigationDestination(for: PokemonSummary.self) { summary in
            PokemonDetailView(viewModel: makeDetailViewModel(summary))
        }
    }
}
