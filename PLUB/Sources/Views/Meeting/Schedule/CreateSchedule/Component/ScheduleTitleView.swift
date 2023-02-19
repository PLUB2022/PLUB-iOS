//
//  ScheduleTitleView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/18.
//

import UIKit

import RxCocoa
import RxSwift

final class ScheduleTitleView: UIView {
  private let scheduleType: MeetingScheduleType
  private lazy var imageView = UIImageView().then {
    $0.image = UIImage(named: scheduleType.imageName)
    $0.contentMode = .scaleAspectFit
  }
  
  private lazy var label = UILabel().then {
    $0.text = scheduleType.rawValue
    $0.font = .subtitle
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  init(type: MeetingScheduleType) {
    scheduleType = type
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    addSubview(label)
    addSubview(imageView)
    switch scheduleType {
    case .date, .location, .memo:
      addSubview(lineView)
    case .alarm:
      break
    }
  }

  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(12.5)
      $0.centerY.equalToSuperview()
      $0.top.bottom.equalToSuperview().inset(16)
      $0.size.equalTo(24)
    }
    
    label.snp.makeConstraints {
      $0.leading.equalTo(imageView.snp.trailing).offset(12.5)
      $0.centerY.equalTo(imageView.snp.centerY)
    }
    
    switch scheduleType {
    case .date, .location, .memo:
      lineView.snp.makeConstraints {
        $0.leading.equalTo(label.snp.leading)
        $0.trailing.equalToSuperview()
        $0.bottom.equalToSuperview()
        $0.height.equalTo(1)
      }
    case .alarm:
      break
    }
  }
}
