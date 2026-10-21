import Foundation

enum OrbitError: LocalizedError {
    case auth(String)
    case denied(String)
    case network(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .auth(let message), .denied(let message), .network(let message), .unknown(let message):
            return message
        }
    }
}
