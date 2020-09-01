import Foundation

public enum PSLoggerLevel {
    case DEBUG, INFO, ERROR
}

public protocol PSLoggerProtocol {
    func log(level: PSLoggerLevel, message: String)
    func log(level: PSLoggerLevel, message: String, request: URLRequest)
    func log(level: PSLoggerLevel, message: String, response: HTTPURLResponse)
    func log(level: PSLoggerLevel, message: String, response: HTTPURLResponse, error: PSApiError)
}
