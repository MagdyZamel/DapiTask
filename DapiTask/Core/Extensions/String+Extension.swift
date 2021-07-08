//
//  String+Extension.swift
//  DapiTask
//
//  Created by MSZ on 08/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation
extension String {
    /// A localized value form Localizable base on current app local.
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}
