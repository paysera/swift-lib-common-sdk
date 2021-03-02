import Alamofire
import Foundation

public class PSRequestAdapter: RequestInterceptor {
    private let headers: PSRequestHeaders?
    private let credentials: PSApiJWTCredentials
    
    public init(credentials: PSApiJWTCredentials, headers: PSRequestHeaders? = nil) {
        self.credentials = credentials
        self.headers = headers
    }
    
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        guard let token = credentials.token?.string else {
            return completion(.failure(PSApiError.unauthorized()))
        }
        
        var urlRequest = urlRequest
        urlRequest.headers.add(.authorization(bearerToken: token))
        
        if let headers = headers {
            headers.headers.forEach {
                urlRequest.headers.add(name: $0.headerKey, value: $0.value)
            }
        }

        completion(.success(urlRequest))
    }
    
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        completion(.doNotRetry)
    }
}
