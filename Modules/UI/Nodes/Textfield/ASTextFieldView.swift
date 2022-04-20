//
//  ASTextFieldView.swift
//  UI
//
//  Created by Boris Verbitsky on 20.04.2022.
//

import UIKit

public final class ASTextFieldView: UITextField {

    // MARK: Public properties
    private var _textContainerInset: UIEdgeInsets?

    public var textContainerInset: UIEdgeInsets? {
        get {
            return _textContainerInset
        }

        set {
            if _textContainerInset != newValue {
                _textContainerInset = newValue
                setNeedsLayout()
            }
        }
    }

    // MARK: Public Methods
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(x: bounds.origin.x + (_textContainerInset?.left ?? 0),
               y: bounds.origin.y + (_textContainerInset?.top ?? 0),
               width: bounds.size.width - (_textContainerInset?.left ?? 0) - (_textContainerInset?.right ?? 0),
               height: bounds.size.height - (_textContainerInset?.top ?? 0) - (_textContainerInset?.bottom ?? 0))
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        textRect(forBounds: bounds)
    }
}
