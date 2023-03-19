//
//  RecruitingFooterView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/18.
//

import UIKit

import SnapKit
import RxSwift

final class RecruitingFooterView: UIView {
  private let disposeBag = DisposeBag()
  
  private let titleLabel = UILabel().then {
    $0.font = .button
    $0.textColor = .deepGray
    $0.text = "지원자가 없습니다!"
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
}

extension RecruitingFooterView {
  private func setupLayouts() {
    addSubview(titleLabel)
  }
  
  private func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
  }
  
  private func setupStyles() {
  }
}
