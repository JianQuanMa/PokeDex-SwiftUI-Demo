import SwiftUI

@main
struct PokeDexApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            PokemonListView(
                viewModel: container.makeListViewModel(),
                makeDetailViewModel: container.makeDetailViewModel(for:)
            )
        }
    }
}
