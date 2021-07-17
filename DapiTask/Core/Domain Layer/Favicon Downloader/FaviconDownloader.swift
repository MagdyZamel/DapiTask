//
//  FaviconDownloader.swift
//  DapiTask
//
//  Created by MSZ on 13/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation
import FaviconFinder

class FaviconDownloader: FaviconDownloaderProtocol {
    /// Download the Favicon from url
    /// - important: The completion should be executed on the custom queue not the **Main**, so don't run UITask on it
    /// - parameter urlString:  The  string value for the URL. of the website that we're trying to extract Favicon from.
    /// - parameter completion: The completion  to call when when get the data or error.
    ///                         This completion **should be executed on the custom queue not the main**.
    ///  - parameter result: Result of  `Error` and `Favicon`  the model  represents  the Favicon holds imageData, and image url
    func downloadFavicon(urlString: String, _ completion: @escaping (_ result: Result<Favicon, Error>) -> Void) {
        guard isValidUrl(urlString),
              let url = URL(string: urlString) else {
            completion(.failure(NSError.FaviconDownloader.urlNotValid(urlString: urlString)))
            return
        }

        FaviconFinder(url: url).downloadFavicon { result in
            switch result {
            case .success(let favicon):
                if let data = favicon.image.pngData() {
                    completion(.success(Favicon(url: url, imageData: data)))
                } else {
                    completion(.failure(NSError.FaviconDownloader.failedDownload(url: url)))
                }
            case .failure:
                completion(.failure(NSError.FaviconDownloader.failedDownload(url: url)))
            }
        }

    }

    func isValidUrl(_ urlString: String) -> Bool {
        let urlRegEx = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        return NSPredicate(format: "SELF MATCHES %@", urlRegEx).evaluate(with: urlString)
    }

}

extension NSError {
    struct FaviconDownloader {
        static func failedDownload(url: URL) -> NSError {
            NSError(domain: "Networking-FaviconDownloader",
                    message: "error.faviconDownloader.failedDownload".localized(with: [url.absoluteString]))
        }
        static func urlNotValid(urlString: String) -> NSError {
            NSError(domain: "Networking-FaviconDownloader",
                    message: "error.faviconDownloader.urlNotValid".localized(with: [urlString]))
        }

    }
}
