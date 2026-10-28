import Foundation

struct PokemonStat: Identifiable, Equatable {
    var id: String { name }
    let name: String
    let value: Int

    var displayName: String {
        name.replacingOccurrences(of: "-", with: " ").capitalized
    }

    /// PokeAPI base stats top out around 255 for the "spread" species
    /// (e.g. Blissey's HP). Normalizing against that gives a reasonable
    /// 0...1 range for a progress bar without special-casing any one stat.
    var normalizedValue: Double {
        min(Double(value) / 255.0, 1.0)
    }
}

struct PokemonDetail: Identifiable, Equatable {
    let id: Int
    let name: String
    let heightDecimeters: Int
    let weightHectograms: Int
    let types: [String]
    let abilities: [String]
    let stats: [PokemonStat]
    let artworkURL: URL?

    var displayName: String { name.capitalized }
    var heightInMeters: Double { Double(heightDecimeters) / 10.0 }
    var weightInKilograms: Double { Double(weightHectograms) / 10.0 }
}

extension PokemonDetail {
    init(dto: PokemonDetailDTO) {
        self.id = dto.id
        self.name = dto.name
        self.heightDecimeters = dto.height
        self.weightHectograms = dto.weight
        self.types = dto.types.map { $0.type.name }
        self.abilities = dto.abilities.map { $0.ability.name }
        self.stats = dto.stats.map { PokemonStat(name: $0.stat.name, value: $0.baseStat) }
        let artworkString = dto.sprites.other?.officialArtwork?.frontDefault ?? dto.sprites.frontDefault
        self.artworkURL = artworkString.flatMap(URL.init(string:))
    }
}
