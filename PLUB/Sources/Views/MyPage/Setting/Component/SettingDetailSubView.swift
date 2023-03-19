//
//  SettingDetailSubView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/19.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

final class SettingDetailSubView: UIView {
  private let label = UILabel().then {
    $0.font = .body1
    $0.textColor = .black
  }
  
  private let arrowImageView = UIImageView().then {
    $0.image = UIImage(named: "arrowRightGray")
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  init(_ title: String, isLast: Bool = false) {
    label.text = title
    super.init(frame: .zero)
    setupLayouts(isLast: isLast)
    setupConstraints(isLast: isLast)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts(isLast: Bool) {
    [label, arrowImageView].forEach {
      addSubview($0)
    }
    
    if !isLast {
      addSubview(lineView)
    }
  }

  private func setupConstraints(isLast: Bool) {
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(12)
      $0.centerY.equalToSuperview()
      $0.height.equalTo(21)
      $0.top.bottom.equalToSuperview().inset(8)
    }
    
    arrowImageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(12)
      $0.centerY.equalToSuperview()
      $0.size.equalTo(20)
    }
    
    if !isLast {
      lineView.snp.makeConstraints {
        $0.leading.trailing.equalToSuperview().inset(10)
        $0.bottom.equalToSuperview()
        $0.height.equalTo(1)
      }
    }
  }
}
