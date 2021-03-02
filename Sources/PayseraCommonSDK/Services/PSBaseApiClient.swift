import Alamofire
import Foundation
import ObjectMapper
import PromiseKit

open class PSBaseApiClient {
    private let session: Session
    private let credentials: PSApiJWTCredentials
    private let tokenRefresher: PSTokenRefresherProtocol?
    private let logger: PSLoggerProtocol?
    private var requestsQueue = [PSApiRequest]()
    
    private var refreshPromise: Promise<Bool>?
    private let workQueue = DispatchQueue(label: "\(PSBaseApiClient.self)")
    
    public init(
        session: Session,
        credentials: PSApiJWTCredentials,
        tokenRefresher: PSTokenRefresherProtocol?,
        logger: PSLoggerProtocol? = nil
    ) {
        self.session = session
        self.tokenRefresher = tokenRefresher
        self.credentials = credentials
        self.logger = logger
    }
    
    public func cancelAllOperations() {
        session.cancelAllRequests()
    }
    
    public func doRequest<RC: URLRequestConvertible, E: Mappable>(requestRouter: RC) -> Promise<[E]> {
        let request = createRequest(requestRouter)
        executeRequest(request)
        
        return request
            .pendingPromise
            .promise
            .map(on: workQueue) { body in
                guard let objects = Mapper<E>().mapArray(JSONObject: body) else {
                    throw self.mapError(body: body)
                }
                return objects
            }
    }
    
    public func doRequest<RC: URLRequestConvertible, E: Mappable>(requestRouter: RC) -> Promise<E> {
        let request = createRequest(requestRouter)
        executeRequest(request)
        
        return request
            .pendingPromise
            .promise
            .map(on: workQueue) { body in
                guard let object = Mapper<E>().map(JSONObject: body) else {
                    throw self.mapError(body: body)
                }
                return object
            }
    }
    
    public func doRequest<RC: URLRequestConvertible>(requestRouter: RC) -> Promise<Any> {
        let request = createRequest(requestRouter)
        executeRequest(request)
        
        return request
            .pendingPromise
            .promise
    }
    
    public func doRequest<RC: URLRequestConvertible>(requestRouter: RC) -> Promise<Void> {
        let request = createRequest(requestRouter)
        executeRequest(request)
        
        return request
            .pendingPromise
            .promise
            .asVoid()
    }
    
    private func createRequest<RC: URLRequestConvertible>(_ endpoint: RC) -> PSApiRequest {
        PSApiRequest(pendingPromise: Promise<Any>.pending(), requestEndPoint: endpoint)
    }
    
    private func executeRequest(_ apiRequest: PSApiRequest) {
        workQueue.async {
            guard let urlRequest = apiRequest.requestEndPoint.urlRequest else {
                return apiRequest.pendingPromise.resolver.reject(PSApiError.unknown())
            }
            
            if self.tokenRefresher != nil, self.credentials.isExpired() {
                self.requestsQueue.append(apiRequest)
                self.refreshToken()
            } else {
                self.logger?.log(
                    level: .DEBUG,
                    message: "--> \(urlRequest.url!.absoluteString)",
                    request: urlRequest
                )
                
                self.session
                    .request(apiRequest.requestEndPoint)
                    .responseJSON(queue: self.workQueue) { response in
                        self.handleResponse(response, for: apiRequest, with: urlRequest)
                    }
            }
        }
    }
    
    private func handleResponse(
        _ response: AFDataResponse<Any>,
        for apiRequest: PSApiRequest,
        with urlRequest: URLRequest
    ) {
        guard let urlResponse = response.response else {
            return handleMissingUrlResponse(for: apiRequest, with: response.error)
        }
        
        let responseData = try? response.result.get()
        let statusCode = urlResponse.statusCode
        let logMessage = "<-- \(urlRequest.url!.absoluteString) \(statusCode)"
        
        if 200 ... 299 ~= statusCode {
            logger?.log(
                level: .DEBUG,
                message: logMessage,
                response: urlResponse
            )
            apiRequest.pendingPromise.resolver.fulfill(responseData ?? "")
        } else {
            let error = mapError(body: responseData)
            error.statusCode = statusCode
            
            logger?.log(
                level: .ERROR,
                message: logMessage,
                response: urlResponse,
                error: error
            )
            
            if statusCode == 401 {
                handleUnauthorizedRequest(apiRequest, error: error)
            } else {
                apiRequest.pendingPromise.resolver.reject(error)
            }
        }
    }
    
    private func handleMissingUrlResponse(
        for apiRequest: PSApiRequest,
        with afError: AFError?
    ) {
        let error: PSApiError
        
        switch afError {
        case .explicitlyCancelled:
            error = .cancelled()
        case .sessionTaskFailed(let e as URLError) where
                e.code == .notConnectedToInternet ||
                e.code == .networkConnectionLost ||
                e.code == .dataNotAllowed:
            error = .noInternet()
        default:
            error = .unknown()
        }
        
        apiRequest.pendingPromise.resolver.reject(error)
    }
    
    private func handleUnauthorizedRequest(
        _ apiRequest: PSApiRequest,
        error: PSApiError
    ) {
        guard tokenRefresher != nil else {
            return apiRequest.pendingPromise.resolver.reject(error)
        }
        
        if credentials.hasRecentlyRefreshed() {
            return executeRequest(apiRequest)
        }
        
        requestsQueue.append(apiRequest)
        refreshToken()
    }
    
    private func mapError(body: Any?) -> PSApiError {
        Mapper<PSApiError>().map(JSONObject: body) ?? .unknown()
    }
    
    private func refreshToken() {
        guard
            refreshPromise == nil,
            let tokenRefresher = tokenRefresher
        else {
            return
        }
        
        refreshPromise = tokenRefresher.refreshToken()
        refreshPromise?
            .done(on: workQueue) { _ in
                self.resumeQueue()
                self.refreshPromise = nil
            }
            .catch(on: workQueue) { error in
                self.cancelQueue(error: error)
                self.refreshPromise = nil
            }
    }
    
    private func resumeQueue() {
        requestsQueue.forEach(executeRequest)
        requestsQueue.removeAll()
    }
    
    private func cancelQueue(error: Error) {
        requestsQueue.forEach { request in
            request.pendingPromise.resolver.reject(error)
        }
        requestsQueue.removeAll()
    }
}
