//
//  UnderlineSegmentedControl.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/10.
//

import UIKit

import SnapKit
import Then

class UnderlineSegmentedControl: UISegmentedControl {
  private var bottomLineView = UIView().then {
    $0.backgroundColor = .mediumGray
  }
  
  private lazy var highlightedView = UIView(
    frame: CGRect(
      x: CGFloat(selectedSegmentIndex * Int(bounds.size.width / CGFloat(numberOfSegments))),
      y: bounds.size.height - 2,
      width: bounds.size.width / CGFloat(numberOfSegments),
      height: 2
    )
  ).then {
    $0.backgroundColor = .main
    addSubview($0)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    removeBackgroundAndDivider()
  }
  
  override init(items: [Any]?) {
    super.init(items: items)
    setupLayouts()
    setupConstraints()
    removeBackgroundAndDivider()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    underlineAnimation()
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
    
  private func removeBackgroundAndDivider() {
    let image = UIImage()
    setBackgroundImage(image, for: .normal, barMetrics: .default)
    setBackgroundImage(image, for: .selected, barMetrics: .default)
    setBackgroundImage(image, for: .highlighted, barMetrics: .default)
    setDividerImage(
      image,
      forLeftSegmentState: .selected,
      rightSegmentState: .normal,
      barMetrics: .default
    )
    backgroundColor = .clear
  }
    
  private func setupLayouts() {
    addSubview(bottomLineView)
  }
  
  private func setupConstraints() {
    bottomLineView.snp.makeConstraints {
      $0.height.equalTo(1)
      $0.bottom.leading.trailing.equalToSuperview()
    }
  }
  
  private func underlineAnimation() {
    layer.cornerRadius = 0
    let segmentIndex = CGFloat(selectedSegmentIndex)
    let segmentWidth = frame.width / CGFloat(numberOfSegments)
    let leadingDistance = segmentWidth * segmentIndex
    UIView.animate(
      withDuration: 0.1,
      animations: {
        self.highlightedView.frame.origin.x = leadingDistance
      }
    )
  }
}
