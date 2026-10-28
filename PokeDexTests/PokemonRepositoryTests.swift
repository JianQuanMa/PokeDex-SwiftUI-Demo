import Testing
import Foundation
@testable import PokeDex

struct PokemonRepositoryTests {
    @Test func fetchAllPokemonNames_parsesIDsFromURLsAndCachesResult() async throws {
        let client = MockAPIClient()
        client.dataToReturn = Fixtures.pokemonListJSON
        let repository = PokemonRepository(apiClient: client)

        let summaries = try await repository.fetchAllPokemonNames()

        #expect(summaries.map(\.id) == [1, 2])
        #expect(summaries.map(\.name) == ["bulbasaur", "ivysaur"])

        // Clear the stubbed payload to prove the second call is served from
        // the repository's in-memory cache rather than hitting the client again.
        client.dataToReturn = nil
        let cached = try await repository.fetchAllPokemonNames()
        #expect(cached.count == 2)
    }

    @Test func fetchPokemonDetail_mapsTypesStatsAndArtwork() async throws {
        let client = MockAPIClient()
        client.dataToReturn = Fixtures.pokemonDetailJSON
        let repository = PokemonRepository(apiClient: client)

        let detail = try await repository.fetchPokemonDetail(id: 1)

        #expect(detail.types == ["grass", "poison"])
        #expect(detail.stats.map(\.value) == [45, 49])
        #expect(detail.artworkURL?.absoluteString == "https://example.com/artwork.png")
    }

    @Test func fetchAllPokemonNames_propagatesNetworkError() async throws {
        let client = MockAPIClient()
        client.errorToThrow = NetworkError.httpError(statusCode: 500)
        let repository = PokemonRepository(apiClient: client)

        await #expect(throws: NetworkError.self) {
            try await repository.fetchAllPokemonNames()
        }
    }
}
