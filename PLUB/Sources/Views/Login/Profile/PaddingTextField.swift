//
//  PaddingTextField.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/04.
//

import UIKit

final class PaddingTextField: UITextField {
  
  // MARK: - Property
  
  var leftViewPadding: CGFloat = 0
  var rightViewPadding: CGFloat = 0
  
  override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var leftViewRect = super.leftViewRect(forBounds: bounds)
    leftViewRect.origin.x += leftViewPadding
    return leftViewRect
  }

  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rightViewRect = super.rightViewRect(forBounds: bounds)
    rightViewRect.origin.x -= rightViewPadding
    return rightViewRect
  }
}
