//
//  Ex+UILabel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/22.
//

import UIKit

extension UILabel {
  func addLineSpacing(_ label: UILabel) {
    let attrString = NSMutableAttributedString(string: label.text!)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.lineSpacing = 4
    attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
    label.attributedText = attrString
  }
}
