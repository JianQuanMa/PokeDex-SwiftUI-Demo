import Foundation

/// Describes a single PokeAPI request. Kept dumb on purpose: it only knows
/// how to build a URL, not how to execute a request or parse a response.
struct Endpoint {
    let path: String
    var queryItems: [URLQueryItem] = []

    static let baseURL = URL(string: "https://pokeapi.co/api/v2")!

    var url: URL? {
        guard var components = URLComponents(
            url: Self.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            return nil
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components.url
    }

    static func pokemonList(limit: Int, offset: Int) -> Endpoint {
        Endpoint(path: "pokemon", queryItems: [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ])
    }

    static func pokemonDetail(id: Int) -> Endpoint {
        Endpoint(path: "pokemon/\(id)")
    }
}
