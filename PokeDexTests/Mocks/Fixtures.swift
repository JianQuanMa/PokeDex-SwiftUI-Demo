import Foundation

enum Fixtures {
    static let pokemonListJSON = """
    {
        "count": 2,
        "next": null,
        "previous": null,
        "results": [
            { "name": "bulbasaur", "url": "https://pokeapi.co/api/v2/pokemon/1/" },
            { "name": "ivysaur", "url": "https://pokeapi.co/api/v2/pokemon/2/" }
        ]
    }
    """.data(using: .utf8)!

    static let pokemonDetailJSON = """
    {
        "id": 1,
        "name": "bulbasaur",
        "height": 7,
        "weight": 69,
        "types": [
            { "type": { "name": "grass" } },
            { "type": { "name": "poison" } }
        ],
        "stats": [
            { "base_stat": 45, "stat": { "name": "hp" } },
            { "base_stat": 49, "stat": { "name": "attack" } }
        ],
        "abilities": [
            { "ability": { "name": "overgrow" } }
        ],
        "sprites": {
            "front_default": "https://example.com/front.png",
            "other": {
                "official-artwork": { "front_default": "https://example.com/artwork.png" }
            }
        }
    }
    """.data(using: .utf8)!
}
