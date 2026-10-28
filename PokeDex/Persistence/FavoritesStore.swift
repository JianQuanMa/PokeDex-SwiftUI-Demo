import Foundation
import SwiftData

/// Protocol seam over favorites persistence, so view models can be unit
/// tested with an in-memory fake instead of a real SwiftData container.
@MainActor
protocol FavoritesStoring: AnyObject {
    var favoriteIDs: Set<Int> { get }
    func isFavorite(id: Int) -> Bool
    func toggleFavorite(id: Int, name: String)
}

@MainActor
final class FavoritesStore: FavoritesStoring {
    private let modelContext: ModelContext
    private(set) var favoriteIDs: Set<Int> = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        refresh()
    }

    func isFavorite(id: Int) -> Bool {
        favoriteIDs.contains(id)
    }

    func toggleFavorite(id: Int, name: String) {
        // Fetches the whole (small) favorites table and filters in Swift
        // rather than using a #Predicate, which traps at runtime on this
        // toolchain when the captured variable shares a name with the
        // compared property.
        let all = try? modelContext.fetch(FetchDescriptor<FavoritePokemon>())
        let existing = all?.first { $0.id == id }

        if let existing {
            modelContext.delete(existing)
        } else {
            modelContext.insert(FavoritePokemon(id: id, name: name))
        }
        try? modelContext.save()
        refresh()
    }

    private func refresh() {
        let all = try? modelContext.fetch(FetchDescriptor<FavoritePokemon>())
        favoriteIDs = Set((all ?? []).map(\.id))
    }
}
