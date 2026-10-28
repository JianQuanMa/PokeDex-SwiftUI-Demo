import Foundation

/// Lightweight domain model used for the list screen. PokeAPI's list
/// endpoint only returns a name + a URL to the detail resource, so we
/// derive the numeric id (and from it, a sprite URL) without an extra
/// network round trip per row.
struct PokemonSummary: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String

    var displayName: String { name.capitalized }

    var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png")
    }
}

extension PokemonSummary {
    init?(dto: PokemonListItemDTO) {
        guard let id = PokemonSummary.extractID(fromResourceURL: dto.url) else { return nil }
        self.id = id
        self.name = dto.name
    }

    private static func extractID(fromResourceURL urlString: String) -> Int? {
        let trimmed = urlString.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let lastComponent = trimmed.split(separator: "/").last else { return nil }
        return Int(lastComponent)
    }
}
