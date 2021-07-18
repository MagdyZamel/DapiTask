//
//  UITableView+Extension.swift
//  DapiTask
//
//  Created by MSZ on 17/07/2021.
//  Copyright © 2021 MSZ. All rights reserved.
//

import UIKit

extension UITableView {

    func register<T: UITableViewCell>(cellType: T.Type) {
        let nib = UINib(nibName: cellType.className, bundle: nil)
        self.register(nib, forCellReuseIdentifier: cellType.className)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        let cell = self.dequeueReusableCell(withIdentifier: T.className, for: indexPath)
        return cell as! T
    }
}

extension Data {
    var uiImage: UIImage? {
        UIImage(data: self)
    }
}
