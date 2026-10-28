import Testing
import SwiftData
@testable import PokeDex

/// Unlike the view model tests above, this one exercises the real
/// SwiftData-backed store against an in-memory container — cheap enough
/// to run on every test invocation, and it proves the persistence layer
/// itself, not just a hand-written fake of it.
@MainActor
struct FavoritesStoreTests {
    @Test func toggleFavorite_addsAndRemovesEntry() throws {
        let store = try Self.makeStore()

        #expect(store.isFavorite(id: 1) == false)

        store.toggleFavorite(id: 1, name: "bulbasaur")
        #expect(store.isFavorite(id: 1) == true)

        store.toggleFavorite(id: 1, name: "bulbasaur")
        #expect(store.isFavorite(id: 1) == false)
    }

    @Test func favoriteIDs_reflectsMultipleEntries() throws {
        let store = try Self.makeStore()

        store.toggleFavorite(id: 1, name: "bulbasaur")
        store.toggleFavorite(id: 4, name: "charmander")

        #expect(store.favoriteIDs == [1, 4])
        #expect(Set(store.favoritePokemons.map(\.id)) == [1, 4])
        #expect(Set(store.favoritePokemons.map(\.name)) == ["bulbasaur", "charmander"])
    }

    private static func makeStore() throws -> FavoritesStore {
        let container = try ModelContainer(
            for: FavoritePokemon.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return FavoritesStore(modelContext: container.mainContext)
    }
}
