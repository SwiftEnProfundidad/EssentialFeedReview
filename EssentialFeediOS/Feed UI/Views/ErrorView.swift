//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Juan Carlos merlos albarracin on 14/10/24.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet public private(set) var button: UIButton!

    public var message: String? { isVisible ? button.title(for: .normal) : nil }

    private var isVisible: Bool {
        alpha > 0
    }

    override public func awakeFromNib() {
        super.awakeFromNib()

        button.setTitle(nil, for: .normal)
        alpha = 0
    }

    func show(message: String) {
        button.setTitle(message, for: .normal)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @IBAction func hideMessage() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed {
                    self.button.setTitle(nil, for: .normal)
                }
            }
        )
    }
}
