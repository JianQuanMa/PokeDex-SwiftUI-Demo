import Foundation
@testable import PokeDex

final class MockAPIClient: APIClientProtocol {
    var dataToReturn: Data?
    var errorToThrow: Error?
    private(set) var requestedEndpoints: [Endpoint] = []

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        if let errorToThrow {
            throw errorToThrow
        }
        guard let data = dataToReturn else {
            throw NetworkError.invalidResponse
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}
