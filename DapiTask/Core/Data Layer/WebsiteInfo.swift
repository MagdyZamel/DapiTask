//
//  WebsiteInfo.swift
//  DapiTask
//
//  Created by MSZ on 14/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation

struct WebsiteInfo {
    var urlString: String
    var favicon: Favicon?
    var websiteMetaData: WebsiteMetaData
}

struct WebsiteMetaData {
    var urlString: String
    var content: Data
    var formatedContentSize: String {
        let contentSize = content.count
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .binary
        return bcf.string(fromByteCount: Int64(contentSize))
    }
}
