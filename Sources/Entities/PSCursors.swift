import ObjectMapper

public class PSCursors: Mappable {
    public var before: String?
    public var after: String?
    
    required public init?(map: Map) { }
    
    public func mapping(map: Map) {
        before  <- map["before"]
        after   <- map["after"]
    }
}
