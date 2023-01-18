//
//  UIColor.swift
//  PLUB
//
//  Created by 양유진 on 2022/09/30.
//

import UIKit

// MARK: - Init

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
}

// MARK: - Plub Color Palette

extension UIColor {
  static let main: UIColor                = .init(hex: 0x5F5FF9)
  static let subMain: UIColor             = .init(hex: 0xB5B5FB)
  static let background: UIColor          = .init(hex: 0xF5F3F6)
  static let deepGray: UIColor            = .init(hex: 0x8C8C8C)
  static let mediumGray: UIColor          = .init(hex: 0xC4C4C4)
  static let lightGray: UIColor           = .init(hex: 0xE4E4E4)
  static let black: UIColor               = .init(hex: 0x363636)
  static let tagBackgroundColor: UIColor  = .init(hex: 0xE1E1FA)
  static let tagTextColor: UIColor        = .init(hex: 0x5F5FF9)
}
