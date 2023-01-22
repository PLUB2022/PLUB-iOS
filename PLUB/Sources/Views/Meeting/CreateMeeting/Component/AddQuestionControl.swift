//
//  AddQuestionControl.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/23.
//

import UIKit

import RxCocoa
import RxSwift

final class AddQuestionControl: UIControl {

  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "plusWhite")
    $0.contentMode = .scaleAspectFit
  }

  private let label = UILabel().then {
    $0.text = "질문 추가"
    $0.font = .button
    $0.textColor = .white
  }
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    setupStyles()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    [imageView, label].forEach {
      addSubview($0)
    }
  }

  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(18)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(14)
    }
    
    label.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(4)
      $0.trailing.equalToSuperview().inset(18)
      $0.centerY.equalTo(imageView.snp.centerY)
    }
  }

  private func setupStyles() {
    layer.cornerRadius = 18
    backgroundColor = .main
  }
}

extension Reactive where Base: AddQuestionControl {
  var tap: ControlEvent<Void> {
    controlEvent(.touchUpInside)
  }
}
