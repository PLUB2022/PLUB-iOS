//
//  IndicatorButton.swift
//  PLUB
//
//  Created by 이건준 on 2022/11/23.
//

import UIKit

import RxSwift
import RxCocoa

enum ToggleType {
  case indicator
  case bookmark
}

class ToggleButton: UIButton {
  
  private let type: ToggleType
  
  override var isSelected: Bool {
    didSet {
      switch type {
      case .indicator:
        isSelected ? setImage(UIImage(named: "topIndicator"), for: .normal) : setImage(UIImage(named: "bottomIndicator"), for: .normal)
      case .bookmark:
        isSelected ? setImage(UIImage(named: "mainBookmark"), for: .normal) : setImage(UIImage(named: "whiteBookmark"), for: .normal)
      }
    }
  }
  
  init(type: ToggleType) {
    self.type = type
    super.init(frame: .zero)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  private func configureUI() {
    setImage(UIImage(named: "bottomIndicator"), for: .normal)
  }
}

extension Reactive where Base: ToggleButton {
  
  var isSelected: ControlProperty<Bool> {
    return base.rx.controlProperty(editingEvents: .touchUpInside) { toggleButton in
      toggleButton.isSelected
    } setter: { toggleButton, value in
      if toggleButton.isSelected != value {
        toggleButton.isSelected = value
      }
    }
  }
}
