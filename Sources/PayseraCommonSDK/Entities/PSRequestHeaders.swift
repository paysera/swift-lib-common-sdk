import ObjectMapper

public class PSRequestHeaders {
    public var headers = [PSURLRequestHeader]()
    
    public init() {
    }
    
    public init(headers: [PSURLRequestHeader]) {
        self.headers = headers
    }
    
    public func updateHeader(_ header: PSURLRequestHeader) {
        headers.removeAll(where: { $0.headerKey == header.headerKey })
        headers.append(header)
    }
}
