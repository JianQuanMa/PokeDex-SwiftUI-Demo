import Testing
@testable import PokeDex

struct EndpointTests {
    @Test func pokemonList_buildsURLWithLimitAndOffset() {
        let endpoint = Endpoint.pokemonList(limit: 20, offset: 40)
        #expect(endpoint.url?.absoluteString.contains("limit=20") == true)
        #expect(endpoint.url?.absoluteString.contains("offset=40") == true)
    }

    @Test func pokemonDetail_buildsURLWithID() {
        let endpoint = Endpoint.pokemonDetail(id: 25)
        #expect(endpoint.url?.absoluteString.hasSuffix("pokemon/25") == true)
    }
}
