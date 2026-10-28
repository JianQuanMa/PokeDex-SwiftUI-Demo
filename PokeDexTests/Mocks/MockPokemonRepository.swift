import Foundation
@testable import PokeDex

final class MockPokemonRepository: PokemonRepositoryProtocol {
    var namesResult: Result<[PokemonSummary], Error> = .success([])
    var detailResult: Result<PokemonDetail, Error>?
    private(set) var detailRequests: [Int] = []

    func fetchAllPokemonNames() async throws -> [PokemonSummary] {
        try namesResult.get()
    }

    func fetchPokemonDetail(id: Int) async throws -> PokemonDetail {
        detailRequests.append(id)
        guard let detailResult else { throw NetworkError.invalidResponse }
        return try detailResult.get()
    }
}
