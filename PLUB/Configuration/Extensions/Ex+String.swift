//
//  Ex + String.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/07.
//

import UIKit

extension String {
  
  /// 라벨 취소선을 설정하는 함수입니다.
  func strikeThrough() -> NSAttributedString {
    let attributeString = NSMutableAttributedString(string: self)
    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, attributeString.length))
    return attributeString
  }
}
