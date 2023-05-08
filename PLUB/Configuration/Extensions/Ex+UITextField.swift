//
//  Ex+UITextField.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/08.
//

import UIKit

extension UITextField {
  
  /// 텍스트필드 밑줄선을 긋는 함수입니다.
  /// - Parameters:
  ///   - color: 밑줄선 색상
  func addUnderline(color: UIColor) {
    let border = CALayer()
    let width = CGFloat(1.0)
    
    border.borderColor = color.cgColor
    border.frame = CGRect(x: 0, y: bounds.size.height - width, width:  bounds.size.width, height: bounds.size.height)
        
    border.borderWidth = width
    layer.addSublayer(border)
    layer.masksToBounds = true
  }
}
