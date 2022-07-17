//
//  Textfield.swift
//  UI
//
//  Created by Boris Verbitsky on 05.06.2022.
//

import UIKit

public class TextField: UITextField {

    // MARK: Private methods
    private let padding = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    // MARK: Override methods
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
