public enum UVError: Error {
    case UV__EOF
    case unknown(Int32)
    case notRunning
    case failedToInit
}

extension UVError {
    init(from data: Int32) {
        switch data {
        case -4095: self = .UV__EOF
        default: self = .unknown(data)
        }
    }

    var code: Int32 {
        switch self {
        case .UV__EOF:
            -4095
        case let .unknown(data):
            data
        case .notRunning:
            1
        case .failedToInit:
            2
        }
    }
}

extension UVError: Equatable {}
