import Foundation
import ObjectMapper

public class PSApiError: Mappable, Error {
    public var error: String?
    public var statusCode: Int?
    public var description: String?
    public var properties: [String: Any]?
    public var data: Any?
    public var errors: [PSApiFieldError]?
    
    public init(error: String? = nil, description: String? = nil, statusCode: Int? = nil) {
        self.error = error
        self.description = description
        self.statusCode = statusCode
    }
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        error       <- map["error"]
        errors      <- map["errors"]
        description <- map["error_description"]
        properties  <- map["error_properties"]
        data        <- map["error_data"]
    }
    
    public func isUnauthorized() -> Bool {
        return error == "unauthorized"
    }
    
    public func isRefreshTokenExpired() -> Bool {
        return error == "invalid_grant"
            && (description == "Refresh token expired" || description == "No such refresh token")
    }
    
    public func isTokenExpired() -> Bool {
        return error == "invalid_grant" && description == "Token has expired"
    }
    
    public func isInvalidTimestamp() -> Bool {
        return error == "invalid_timestamp"
    }
    
    public func isNoInternet() -> Bool {
        return error == "no_internet"
    }
    
    class public func unknown() -> PSApiError {
        return PSApiError(error: "unknown")
    }
    
    class public func unauthorized() -> PSApiError {
        return PSApiError(error: "unauthorized")
    }
    
    public class func mapping(json: String) -> PSApiError {
        return PSApiError(error: "mapping", description: "mapping failed: \(json)")
    }
    
    public class func noInternet() -> PSApiError {
        return PSApiError(error: "no_internet", description: "No internet connection")
    }
    
    public class func cancelled() -> PSApiError {
        return PSApiError(error: "cancelled")
    }
}

public class PSApiFieldError: Mappable {
    public var code: String!
    public var field: String!
    public var message: String!
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        code    <- map["code"]
        field   <- map["field"]
        message <- map["message"]
    }
}
