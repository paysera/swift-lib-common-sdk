import ObjectMapper

public class PSMetadata: Mappable {
    public var total: Int!
    public var offset: Int!
    public var limit: Int!
    public var cursors: PSCursors?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        total   <- map["total"]
        offset  <- map["offset"]
        limit   <- map["limit"]
        cursors <- map["cursors"]
    }
}
