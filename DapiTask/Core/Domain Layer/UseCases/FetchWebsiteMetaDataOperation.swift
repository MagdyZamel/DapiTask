//
//  FetchWebsiteInfoOperation.swift
//  DapiTask
//
//  Created by MSZ on 15/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation

/// Error that could be thrown  as a result from  `FetchWebsiteInfoOperation`
enum FetchWebsiteInfoOperationError: Error {
    /// if the Operation canceled for any reason
    case canceled
    /// if the website url is not valid
    case urlNotValid
    /// any underlying error with type `Error` protocol
    case underlying(error: Error)
    /// if the request failed
    case requestFailed(statusCode: Int)
}

/// FetchWebsiteInfoOperation is a AsyncOperation that used to Fetch website meta data and store it as a `result` of  type `WebsiteMetaData` when it's fulfilled with data  and `FetchWebsiteInfoOperationError` when it fulfilled with error.
class FetchWebsiteMetaDataOperation: AsyncOperation {
    /// the result of the operation  after doing it's work, this property will hold data or error.
    /// - important: don't use it before make sure the operation finished it work.
    private(set) public var result: Result<WebsiteMetaData, FetchWebsiteInfoOperationError>?

    private(set) var websiteStringURL: String
    private var dataTask: URLSessionTask?
    private var urlSession: URLSession

    /// - parameter websiteStringURL: that is a string of the website url of the  website that needed to fetch it's meta data
    /// - parameter urlSession: The URLSession  that be used to fire the  network request also it's  injected dependency to be mocked incase any unite test written.
    init(urlSession: URLSession,
         websiteStringURL: String) {
        self.urlSession = urlSession
        self.websiteStringURL = websiteStringURL

    }

    override func main() {
        guard let websiteURL = URL(string: websiteStringURL) else {
            self.finish(with: .failure(.urlNotValid))
            return
        }
        dataTask = urlSession.dataTask(with: websiteURL, completionHandler: {[weak self] data, response, error in
            guard let self = self, !self.isCancelled else {
                self?.finish(with: .failure(.canceled))
                return
            }
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200, let data = data {
                    self.finish(with: .success(WebsiteMetaData(urlString: self.websiteStringURL,
                                                               content: data)))
                } else {
                    self.finish(with: .failure(.requestFailed(statusCode: response.statusCode)))
                }

            } else {
                let error = error  ?? FetchWebsiteInfoOperationError.canceled
                self.finish(with: .failure(.underlying(error: error)))
                return
            }
        })
        dataTask?.resume()
    }

    private func finish(with result: Result<WebsiteMetaData, FetchWebsiteInfoOperationError>) {
        self.result = result
        set(state: .finished)

    }

    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }

}
