//
//  FaviconDownloaderProtocol.swift
//  DapiTask
//
//  Created by MSZ on 14/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation

struct  Favicon {
    /// The URL of the site we're trying to extract from
    let url: URL
    /// The actual Data of the Favicon
    let imageData: Data
}

protocol FaviconDownloaderProtocol: AnyObject {
    /// Download the Favicon from url
    /// - important: The completion should be executed on the custom queue not the **Main**, so don't run UITask on it
    /// - parameter urlString:  The  string value for the URL. of the website that we're trying to extract Favicon from.
    /// - parameter completion: The completion  to call when when get the data or error.
    ///                         This completion **should be executed on the custom queue not the main**.
    ///  - parameter result: Result of  `Error` and `Favicon`  the model  represents  the Favicon holds imageData, and image url
    func downloadFavicon(urlString: String, _ completion: @escaping (_ result: Result<Favicon, Error>) -> Void)
}
