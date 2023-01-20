import UIKit

extension UIFont {
  private enum Pretendard: String {
    
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
  static let overLine = UIFont(name: Pretendard.regular.rawValue, size: 10)
}
