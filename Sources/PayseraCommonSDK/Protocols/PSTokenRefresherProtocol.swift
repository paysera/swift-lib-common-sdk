import Foundation
import PromiseKit

public protocol PSTokenRefresherProtocol {
    func refreshToken() -> Promise<Bool>
    func isRefreshing() -> Bool
}
