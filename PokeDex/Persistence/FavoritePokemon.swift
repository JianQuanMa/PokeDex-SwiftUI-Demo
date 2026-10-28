import Foundation
import SwiftData

@Model
final class FavoritePokemon {
    @Attribute(.unique) var id: Int
    var name: String
    var addedAt: Date

    init(id: Int, name: String, addedAt: Date = .now) {
        self.id = id
        self.name = name
        self.addedAt = addedAt
    }
}
