import Foundation

enum AppError: Error {
    case validation(String)
    case network(String)
    case internalError(String)

    var message: String {
        switch self {
        case .validation(let s): return s
        case .network(let s): return s
        case .internalError(let s): return s
        }
    }
}
