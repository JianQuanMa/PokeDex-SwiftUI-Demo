import SwiftUI

struct FavoritesListView: View {
    @State private var viewModel: FavoritesListViewModel
    private let makeDetailViewModel: (PokemonSummary) -> PokemonDetailViewModel

    init(
        viewModel: FavoritesListViewModel,
        makeDetailViewModel: @escaping (PokemonSummary) -> PokemonDetailViewModel
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favorites.isEmpty {
                    ContentUnavailableView(
                        "No Favorites Yet",
                        systemImage: "star",
                        description: Text("Tap the star on any Pokémon to add it here.")
                    )
                } else {
                    list
                }
            }
            .navigationTitle("Favorites")
        }
    }

    private var list: some View {
        List(viewModel.favorites) { pokemon in
            NavigationLink(value: pokemon) {
                PokemonRowView(
                    pokemon: pokemon,
                    isFavorite: viewModel.isFavorite(pokemon),
                    onToggleFavorite: { viewModel.removeFavorite(pokemon) }
                )
            }
        }
        .navigationDestination(for: PokemonSummary.self) { summary in
            PokemonDetailView(viewModel: makeDetailViewModel(summary))
        }
    }
}
