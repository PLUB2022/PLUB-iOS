//
//  PaddingTextField.swift
//  PLUB
//
//  Created by 홍승현 on 2023/01/04.
//

import UIKit

final class PaddingTextField: UITextField {
  
  // MARK: - Property
  
  /// leftView의 left padding을 설정합니다.
  /// 양수 값이 클 수록 왼쪽으로부터 멀리 떨어지며, 음수 값을 줄 경우, 왼쪽 라인을 넘어가 parent view를 벗어납니다.
  var leftViewPadding: CGFloat = 0 {
    didSet {
      self.leftViewRect(forBounds: bounds)
    }
  }
  
  /// rightView의 right padding을 설정합니다.
  /// 양수 값이 클 수록 오른쪽으로부터 멀리 떨어지며, 음수 값을 줄 경우, 오른쪽 라인을 넘어가므로 parent view를 벗어납니다.
  var rightViewPadding: CGFloat = 0 {
    didSet {
      self.rightViewRect(forBounds: bounds)
    }
  }
  
  // MARK: - Initialization
  
  /// Inset을 주어 좌우 패딩을 설정합니다.
  /// - Parameter edgeInset: UIEdgeInset, `top inset`과 `bottom inset`은 동작하지 않습니다.
  convenience init(edgeInset: UIEdgeInsets) {
    self.init(frame: .zero)
    let tempView = UIView()
    leftView = tempView
    rightView = tempView
    leftViewMode = .always
    rightViewMode = .always
    leftViewPadding = edgeInset.left
    rightViewPadding = edgeInset.right
  }
  
  // MARK: - Methods
  
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
