import ObjectMapper

public class PSMetadataAwareResponse<T: Mappable>: Mappable {
    public var items: [T]!
    public var metaData: PSMetadata?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        let key = map.JSON.keys.filter { $0 != "_metadata" }.first ?? "items"
        
        items       <- map[key]
        metaData    <- map["_metadata"]
    }
}
