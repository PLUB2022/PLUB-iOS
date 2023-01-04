//
//  IDCheckTextField.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/04.
//

import UIKit

final class IDCheckTextField: UITextField {
  
  override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
    var leftViewRect = super.leftViewRect(forBounds: bounds)
    leftViewRect.origin.x += 8
    return leftViewRect
  }

  override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
    var rightViewRect = super.rightViewRect(forBounds: bounds)
    rightViewRect.origin.x -= 8
    return rightViewRect
  }
}
