import Foundation
import JWTDecode

public class PSApiJWTCredentials {
    public var token: JWT?
    
    public init(token: JWT? = nil) {
        self.token = token
    }
    
    public func isExpired() -> Bool {
        if let token = token {
            return token.expiresAt!.timeIntervalSinceNow < 120
        }
        return false
    }
    
    public func hasRecentlyRefreshed() -> Bool {
        guard let token = token else {
            return false
        }
        
        return abs(token.issuedAt!.timeIntervalSinceNow) < 15
    }
}
