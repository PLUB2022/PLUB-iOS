//
//  UIColor.swift
//  PLUB
//
//  Created by 양유진 on 2022/09/30.
//

import UIKit

extension UIColor {
  
  /// 16진수(hex code)를 이용하여 색상을 지정합니다.
  ///
  /// ```
  /// let color: UIColor = UIColor(hex: 0xF5663F)
  /// ```
  /// - Parameters:
  ///   - hex: 16진수의 Unsigned Int 값
  ///   - alpha: 투명도를 설정합니다. 0과 1사이의 값을 가져야합니다.
  convenience init(hex: UInt, alpha: CGFloat = 1.0) {
    self.init(
      red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(hex & 0x0000FF) / 255.0,
      alpha: CGFloat(alpha)
    )
  }
  
  // MARK: 메인 테마 색 또는 자주 쓰는 색을 정의
  // ex. label.textColor = .mainOrange
  static var mainOrange: UIColor { UIColor(hex: 0xF5663F) }
}
