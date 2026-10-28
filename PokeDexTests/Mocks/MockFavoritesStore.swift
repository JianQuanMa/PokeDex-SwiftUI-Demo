import Foundation
@testable import PokeDex

@MainActor
final class MockFavoritesStore: FavoritesStoring {
    private(set) var favoriteIDs: Set<Int> = []
    private(set) var toggledIDs: [Int] = []

    func isFavorite(id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(id: Int, name: String) {
        toggledIDs.append(id)
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
    }
}
