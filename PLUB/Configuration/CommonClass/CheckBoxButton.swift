//
//  CheckBoxButton.swift
//  PLUB
//
//  Created by 홍승현 on 2022/11/14.
//

import UIKit

import RxSwift
import RxCocoa

final class CheckBoxButton: UIButton {

  private let checkStyle: ButtonType
  
  init(type: ButtonType) {
    self.checkStyle = type
    super.init(frame: .zero)
    setupStyles()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupStyles() {
    self.layer.cornerRadius = 3
    switch checkStyle {
    case .full:
      self.setImage(Image.checkShape, for: .normal)
      self.backgroundColor = .lightGray
    case .none:
      self.backgroundColor = .white
      self.layer.borderWidth = 2
      self.layer.borderColor = UIColor.lightGray.cgColor
    }
  }
}

extension CheckBoxButton {
  enum ButtonType {
    
    /// 체크되어있지 않을 때 비어있는 칸으로 보입니다.
    case none
    
    /// 체크되어있지 않을 때 회색의 체크표시 모양이 보입니다.
    case full
  }
}

extension CheckBoxButton {
  private enum Image {
    static let checkShape = UIImage(named: "Check")
  }
}
