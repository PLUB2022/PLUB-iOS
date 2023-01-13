//
//  IndicatorButton.swift
//  PLUB
//
//  Created by 이건준 on 2022/11/23.
//

import UIKit

class IndicatorButton: UIButton {
  
  override var isSelected: Bool {
    didSet {
      isSelected ? setImage(UIImage(named: "topIndicator"), for: .normal) : setImage(UIImage(named: "bottomIndicator"), for: .normal)
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    setImage(UIImage(named: "bottomIndicator"), for: .normal)
  }
}
