//
//  Ex+CALayer.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/17.
//

import UIKit

extension CALayer {
  func applyShadow(
    color: UIColor = .init(hex: 0x000000),
    alpha: Float = 0.5,
    x: CGFloat = 0,
    y: CGFloat = 2,
    blur: CGFloat = 4,
    spread: CGFloat = 0
  ) {
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: x, height: y)
    shadowRadius = blur / 2.0
    
    guard spread != 0 else { shadowPath = nil; return }
    
    let dxValue = -spread
    let rect = bounds.insetBy(dx: dxValue, dy: dxValue)
    shadowPath = UIBezierPath(rect: rect).cgPath
  }
}
