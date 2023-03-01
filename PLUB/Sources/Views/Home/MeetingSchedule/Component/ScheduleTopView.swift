//
//  ScheduleTopView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/24.
//

import UIKit

import RxCocoa
import RxSwift

final class ScheduleTopView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.text = "모임일정"
    $0.font = .h3
  }
  
  let addScheduleControl = AddScheduleControl()
  
  init() {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    [titleLabel, addScheduleControl].forEach {
      addSubview($0)
    }
  }

  private func setupConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
      $0.height.equalTo(32)
    }
    
    addScheduleControl.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalToSuperview()
      $0.height.equalTo(32)
    }
  }
}
