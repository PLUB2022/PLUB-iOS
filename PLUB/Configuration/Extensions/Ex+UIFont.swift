import UIKit

extension UIFont {
  
  enum FontFamily {
    case pretendard(option: Pretendard)
    case nanum
  }
  
  enum Pretendard: String {
    
    // black
    case black = "Pretendard-Black"
    
    // bold
    case extraBold = "Pretendard-ExtraBold"
    case bold = "Pretendard-Bold"
    case semiBold = "Pretendard-SemiBold"
    
    // medium
    case medium = "Pretendard-Medium"
    
    // regular
    case regular = "Pretendard-Regular"
    
    // light
    case light = "Pretendard-Light"
    case extraLight = "Pretendard-ExtraLight"
    
    // thin
    case thin = "Pretendard-Thin"
  }
  
  enum Nanum: String {
    case `default` = "NanumPenOTF"
  }
}

extension UIFont {
  static let h1 = UIFont(name: Pretendard.bold.rawValue, size: 32)
  static let h2 = UIFont(name: Pretendard.bold.rawValue, size: 28)
  static let h3 = UIFont(name: Pretendard.semiBold.rawValue, size: 24)
  static let h4 = UIFont(name: Pretendard.semiBold.rawValue, size: 20)
  static let h5 = UIFont(name: Pretendard.semiBold.rawValue, size: 18)
  static let subtitle = UIFont(name: Pretendard.semiBold.rawValue, size: 16)
  static let body1 = UIFont(name: Pretendard.semiBold.rawValue, size: 16)
  static let body2 = UIFont(name: Pretendard.regular.rawValue, size: 16)
  static let body3 = UIFont(name: Pretendard.medium.rawValue, size: 16)
  static let button = UIFont(name: Pretendard.bold.rawValue, size: 14)
  static let caption = UIFont(name: Pretendard.regular.rawValue, size: 12)
  static let caption2 = UIFont(name: Pretendard.bold.rawValue, size: 12)
  static let caption3 = UIFont(name: Pretendard.medium.rawValue, size: 12)
  static let overLine = UIFont(name: Pretendard.regular.rawValue, size: 10)
  
  static let onboarding = UIFont(name: Nanum.default.rawValue, size: 36)
  
  /// PLUB에서  사용되는 Font-Family를 Custom으로 설정합니다.
  /// - Parameters:
  ///   - family: PLUB에서 사용하는 font-family
  ///   - size: font size
  static func appFont(family: FontFamily, size: CGFloat) -> UIFont {
    switch family {
    case .pretendard(let option):
      return UIFont(name: option.rawValue, size: size) ?? systemFont(ofSize: size)
    case .nanum:
      return UIFont(name: Nanum.default.rawValue, size: size) ?? systemFont(ofSize: size)
    }
  }
}
