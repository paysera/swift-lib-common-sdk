import ObjectMapper

public class PSApiError: Mappable, Error {
    public var error: String?
    public var statusCode: Int?
    public var description: String?
    public var properties: [String: Any]?
    public var data: Any?
    public var errors: [PSApiFieldError]?
    
    public init(
        error: String? = nil,
        description: String? = nil,
        statusCode: Int? = nil,
        data: Any? = nil
    ) {
        self.error = error
        self.description = description
        self.statusCode = statusCode
        self.data = data
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
        error == "unauthorized"
    }
    
    public func isRefreshTokenExpired() -> Bool {
        guard let description = description else {
            return false
        }
        
        let expirationReasons = [
            "Refresh token expired",
            "No such refresh token",
            "Refresh token status invalid",
        ]
        
        return error == "invalid_grant" && expirationReasons.contains(description)
    }
    
    public func isTokenExpired() -> Bool {
        error == "invalid_grant" && description == "Token has expired"
    }
    
    public func isInvalidTimestamp() -> Bool {
        error == "invalid_timestamp"
    }
    
    public func isNoInternet() -> Bool {
        error == "no_internet"
    }
    
    class public func unknown() -> PSApiError {
        PSApiError(error: "unknown")
    }
    
    class public func unauthorized() -> PSApiError {
        PSApiError(error: "unauthorized")
    }
    
    public class func mapping(json: String) -> PSApiError {
        PSApiError(
            error: "internal_mapping_failure",
            description: "Mapping failed: \(json)",
            data: json
        )
    }
    
    public class func noInternet() -> PSApiError {
        PSApiError(error: "no_internet", description: "No internet connection")
    }
    
    public class func internalServerError() -> PSApiError {
        PSApiError(error: "internal_server_error", description: "Server Error")
    }
    
    public class func cancelled() -> PSApiError {
        PSApiError(error: "cancelled")
    }
    
    public class func silenced() -> PSApiError {
        PSApiError(error: nil)
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
