//
//  MeetingTypeControl.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/26.
//

import UIKit

class MeetingTypeControl: UISegmentedControl {  
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundColor = .white
    tintColor = .white
    layer.cornerRadius = CGRectGetHeight(bounds) / 2
    layer.masksToBounds = true
    clipsToBounds = true
    
    let segmentInset: CGFloat = 4
    let foregroundIndex = numberOfSegments
    
    let segmentImage = UIImage(color: .main)
    
    if subviews.indices.contains(foregroundIndex),
       let foregroundImageView = subviews[foregroundIndex] as? UIImageView
    {
      foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
      foregroundImageView.image = segmentImage
      foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")
      foregroundImageView.layer.masksToBounds = true
      foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height / 2
    }
  }
}
