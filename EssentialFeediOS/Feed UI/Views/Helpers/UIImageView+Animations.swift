//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 24/9/24.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage

        guard newImage != nil else { return }
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
