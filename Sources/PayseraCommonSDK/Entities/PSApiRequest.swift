import Alamofire
import PromiseKit

public class PSApiRequest {
    public let requestEndPoint: URLRequestConvertible
    public let pendingPromise: (promise: Promise<Any>, resolver: Resolver<Any>)
    
    public required init<T: URLRequestConvertible>(
        pendingPromise: (promise: Promise<Any>,
        resolver: Resolver<Any>), requestEndPoint: T
    ) {
        self.pendingPromise = pendingPromise
        self.requestEndPoint = requestEndPoint
    }
}
