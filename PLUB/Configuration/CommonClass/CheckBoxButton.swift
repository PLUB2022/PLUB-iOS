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
  
  // MARK: - Property
  
  private let checkStyle: ButtonType
  
  private let disposeBag = DisposeBag()
  
  /// 체크가 되어있다면 `true`, 아니면 `false`를 리턴합니다.
  var isChecked = false {
    willSet {
      switch checkStyle {
      case .full:
        self.backgroundColor    = newValue ? .main : .lightGray
      case .none:
        self.backgroundColor    = newValue ? .main : .white
        self.layer.borderColor  = newValue ? UIColor.main.cgColor : UIColor.lightGray.cgColor
        
        // 체크모양 이미지 설정
        newValue ? setImage(Image.checkShape, for: .normal) : setImage(nil, for: .normal)
      }
    }
  }
  
  // MARK: - Init
  
  init(type: ButtonType) {
    self.checkStyle = type
    super.init(frame: .zero)
    setupStyles()
    bind()
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
  
  private func bind() {
    self.rx.tap
      .bind { [weak self] in
        self?.isChecked.toggle()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Enum

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

// MARK: - RxSwift Custom Property

extension Reactive where Base: CheckBoxButton {
  
  var isChecked: ControlProperty<Bool> {
    return base.rx.controlProperty(editingEvents: .touchUpInside) { checkbox in
      checkbox.isChecked
    } setter: { checkbox, value in
      if checkbox.isChecked != value {
        checkbox.isChecked = value
      }
    }
  }
}
