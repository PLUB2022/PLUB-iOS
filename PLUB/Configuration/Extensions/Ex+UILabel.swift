//
//  Ex+UILabel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/22.
//

import UIKit

extension UILabel {
  func addLineSpacing(lineSpacing: CGFloat = 4) {
    let attrString = NSMutableAttributedString(string: self.text!)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = lineSpacing
    attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
    self.attributedText = attrString
  }
}
