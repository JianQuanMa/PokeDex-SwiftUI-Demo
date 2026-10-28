import Foundation

// Raw shapes returned by PokeAPI. These mirror the JSON exactly and never
// leak outside the Data layer — everything above talks to the mapped
// domain models in PokemonSummary.swift / PokemonDetail.swift.

struct PokemonListResponseDTO: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [PokemonListItemDTO]
}

struct PokemonListItemDTO: Decodable {
    let name: String
    let url: String
}

struct PokemonDetailDTO: Decodable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [PokemonTypeSlotDTO]
    let stats: [PokemonStatSlotDTO]
    let abilities: [PokemonAbilitySlotDTO]
    let sprites: PokemonSpritesDTO
}

struct PokemonTypeSlotDTO: Decodable {
    let type: NamedResourceDTO
}

struct PokemonStatSlotDTO: Decodable {
    let baseStat: Int
    let stat: NamedResourceDTO
}

struct PokemonAbilitySlotDTO: Decodable {
    let ability: NamedResourceDTO
}

struct NamedResourceDTO: Decodable {
    let name: String
}

struct PokemonSpritesDTO: Decodable {
    let frontDefault: String?
    let other: PokemonOtherSpritesDTO?
}

struct PokemonOtherSpritesDTO: Decodable {
    let officialArtwork: PokemonArtworkDTO?

    enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

struct PokemonArtworkDTO: Decodable {
    let frontDefault: String?
}
