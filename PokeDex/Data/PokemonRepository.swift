import Foundation

/// Mediates between the API client and the rest of the app, mapping DTOs
/// to domain models and caching results so the UI layer never has to
/// think about network shapes or repeat work.
protocol PokemonRepositoryProtocol {
    func fetchAllPokemonNames() async throws -> [PokemonSummary]
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail
}

/// An `actor` rather than a `class`: the in-memory caches below are
/// mutated from `async` call sites, and actor isolation gives us
/// data-race safety for free instead of a manual lock.
actor PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: APIClientProtocol
    private var cachedSummaries: [PokemonSummary]?
    private var detailCache: [Int: PokemonDetail] = [:]

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchAllPokemonNames() async throws -> [PokemonSummary] {
        if let cached = cachedSummaries {
            return cached
        }
        // PokeAPI's full roster is small enough to fetch in one call, which
        // lets the list screen page and search entirely client-side.
        let response: PokemonListResponseDTO = try await apiClient.request(.pokemonList(limit: 1302, offset: 0))
        let summaries = response.results.compactMap(PokemonSummary.init(dto:))
        cachedSummaries = summaries
        return summaries
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        if let cached = detailCache[id] {
            return cached
        }
        let dto: PokemonDetailDTO = try await apiClient.request(.pokemonDetail(id: id))
        let detail = PokemonDetail(dto: dto)
        detailCache[id] = detail
        return detail
    }
}
