//
//  SettingSubview.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/19.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class SettingSubview: UIView {
  private let label = UILabel().then {
    $0.font = .appFont(family: .pretendard(option: .bold), size: 18)
    $0.textColor = .black
  }

  init(_ title: String) {
    label.text = title
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    addSubview(label)
  }

  private func setupConstraints() {
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(12)
      $0.centerY.equalToSuperview()
      $0.height.equalTo(21)
      $0.top.equalToSuperview().inset(19)
      $0.bottom.equalToSuperview().inset(10)
    }
  }
}
