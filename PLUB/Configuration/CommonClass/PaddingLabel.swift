//
//  PaddingLabel.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/31.
//

import UIKit

class PaddingLabel: UILabel {
  private var topInset: CGFloat
  private var bottomInset: CGFloat
  private var leftInset: CGFloat
  private var rightInset: CGFloat
  
  required init(
    withInsets top: CGFloat = 0,
    _ bottom: CGFloat = 0,
    _ left: CGFloat = 0,
    _ right: CGFloat = 0
  ) {
    topInset = top
    bottomInset = bottom
    leftInset = left
    rightInset = right
    super.init(frame: CGRect.zero)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets(
      top: topInset,
      left: leftInset,
      bottom: bottomInset,
      right: rightInset
    )
    
    super.drawText(in: rect.inset(by: insets))
  }
  
  override var intrinsicContentSize: CGSize {
    get {
      var contentSize = super.intrinsicContentSize
      contentSize.height += topInset + bottomInset
      contentSize.width += leftInset + rightInset
      return contentSize
    }
  }
}
