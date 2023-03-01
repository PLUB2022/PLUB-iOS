//
//  AddScheduleControl.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/24.
//
import UIKit

import RxCocoa
import RxSwift

final class AddScheduleControl: UIControl {

  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "plusWhite")
    $0.contentMode = .scaleAspectFit
  }

  private let label = UILabel().then {
    $0.text = "일정 추가하기"
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
      $0.leading.equalToSuperview().inset(8)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(14)
    }
    
    label.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(4)
      $0.centerY.equalTo(imageView.snp.centerY)
      $0.trailing.equalToSuperview().inset(10)
    }
  }

  private func setupStyles() {
    layer.cornerRadius = 16
    backgroundColor = .main
  }
}

extension Reactive where Base: AddScheduleControl {
  var tap: ControlEvent<Void> {
    controlEvent(.touchUpInside)
  }
}
