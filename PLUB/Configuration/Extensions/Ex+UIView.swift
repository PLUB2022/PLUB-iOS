//
//  UIView + extension.swift
//  PLUB
//
//  Created by 이건준 on 2022/12/27.
//

import UIKit

extension UIView {
  func addShadow(cornerRadius: CGFloat) {
    layer.cornerRadius = cornerRadius
    layer.masksToBounds = false
    layer.shadowRadius = 4.0
    layer.shadowOpacity = 0.30
    layer.shadowColor = UIColor.gray.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 5)
  }
  
  func roundCorners(corners: UIRectCorner, radius: CGFloat) {
    let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    layer.mask = mask
  }
}
