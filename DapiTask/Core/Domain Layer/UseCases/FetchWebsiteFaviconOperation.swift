//
//  FetchWebsiteFaviconOperation.swift
//  DapiTask
//
//  Created by MSZ on 16/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation

/// FetchWebsiteInfoOperation is a AsyncOperation that used to Fetch website Favicon and store it as a `result` of  type `Favicon` when it's fulfilled with data
class FetchWebsiteFaviconOperation: AsyncOperation {
    /// the result of the operation  after doing it's work, this property will hold data or error.
    /// - important: don't use it before make sure the operation finished it work.
    private(set) public var result: Result<Favicon, Error>?

    private var websiteStringURL: String
    private var faviconDownloader: FaviconDownloaderProtocol

    /// - parameter websiteStringURL: that is a string of the website url of the  website that needed to fetch it's meta data
    /// - parameter faviconDownloader: The FaviconDownloader  that be used to fire the  get the  Favicon
    init(faviconDownloader: FaviconDownloaderProtocol,
         websiteStringURL: String) {
        self.faviconDownloader = faviconDownloader
        self.websiteStringURL = websiteStringURL
    }

    override func main() {
        faviconDownloader.downloadFavicon(urlString: websiteStringURL) { [weak self] result in
            self?.finish(with: result)
        }
    }

    private func finish(with result: Result<Favicon, Error>) {
        self.result = result
        set(state: .finished)
    }
}
