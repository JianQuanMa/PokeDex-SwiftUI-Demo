import SwiftUI

struct RootView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            PokemonListView(
                viewModel: container.makeListViewModel(),
                makeDetailViewModel: container.makeDetailViewModel(for:)
            )
            .tabItem { Label("Pokémon", systemImage: "list.bullet") }

            FavoritesListView(
                viewModel: container.makeFavoritesListViewModel(),
                makeDetailViewModel: container.makeDetailViewModel(for:)
            )
            .tabItem { Label("Favorites", systemImage: "star.fill") }
        }
    }
}
