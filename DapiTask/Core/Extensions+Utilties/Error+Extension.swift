//
//  Error+Extension.swift
//  DapiTask
//
//  Created by MSZ on 14/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import Foundation

extension Error {
    static var userMessageKey: String {"userMessage"}
    /// A user friendly message  form error on current app local.
    var message: String {
        let error = self as NSError
        return (error.userInfo[Self.userMessageKey]  as? String) ?? error.localizedDescription
    }
}

extension NSError {
    convenience init(domain: String,
                     code: Int = 1000,
                     message: String ) {
        self.init(domain: domain,
                  code: code,
                  userInfo: [NSError.userMessageKey: message])
    }
}

extension Result {
    var value: Success? {
        switch self {
        case .success(let value): return value
        default:
            return nil
        }
    }
    var error: Failure? {
        switch self {
        case .failure(let error): return error
        default:
            return nil
        }
    }
}

extension NSObject {
    /// value that represent a className as string value
    static var className: String {
        return String(describing: self)
    }

     var className: String {
        return String(describing: self)
    }
}
