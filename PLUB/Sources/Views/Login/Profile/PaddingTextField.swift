//
//  PaddingTextField.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/04.
//

import UIKit

final class PaddingTextField: UITextField {
  
  // MARK: - Property
  
  var leftViewPadding: CGFloat = 0 {
    didSet {
      self.leftViewRect(forBounds: bounds)
    }
  }
  
  var rightViewPadding: CGFloat = 0 {
    didSet {
      self.rightViewRect(forBounds: bounds)
    }
  }
  
  @discardableResult
  override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var leftViewRect = super.leftViewRect(forBounds: bounds)
    leftViewRect.origin.x += leftViewPadding
    return leftViewRect
  }

  @discardableResult
  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rightViewRect = super.rightViewRect(forBounds: bounds)
    rightViewRect.origin.x -= rightViewPadding
    return rightViewRect
  }
}
