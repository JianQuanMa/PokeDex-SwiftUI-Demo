import Foundation

enum NetworkError: Error, Equatable, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed
    case underlying(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .httpError(let statusCode):
            return "The server responded with status code \(statusCode)."
        case .decodingFailed:
            return "Failed to parse the server response."
        case .underlying(let message):
            return message
        }
    }
}
