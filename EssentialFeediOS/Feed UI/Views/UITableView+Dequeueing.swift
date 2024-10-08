//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 24/9/24.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
