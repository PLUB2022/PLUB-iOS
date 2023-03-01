//
//  ScheduleAlarmControl.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/19.
//

import UIKit

import RxCocoa
import RxSwift

enum ScheduleAlarmType: String, CaseIterable {
  case none = "없음"
  case before5Minute = "5분 전"
  case before15Minute = "15분 전"
  case before30Minute = "30분 전"
  case before1Hour = "1시간 전"
  case before1Day = "1일 전"
  case before1Week = "1주 전"
  
  var value: String {
    switch self {
    case .none:
      return "NONE"
    case .before5Minute:
      return "FIVE_MINUTES"
    case .before15Minute:
      return "TEN_MINUTES"
    case .before30Minute:
      return "THIRTY_MINUTES"
    case .before1Hour:
      return "ONE_HOUR"
    case .before1Day:
      return "ONE_DAY"
    case .before1Week:
      return "ONE_WEEK"
    }
  }
}

protocol ScheduleAlarmDelegate: AnyObject {
  func selectAlarm(alarm: ScheduleAlarmType)
}

final class ScheduleAlarmView: UIView {
  weak var delegate: ScheduleAlarmDelegate?
  
  private let imageView = UIImageView().then {
    $0.image = UIImage(named: "arrowUpDownGray")
    $0.contentMode = .scaleAspectFit
  }
  
  private let label = UILabel().then {
    $0.text = "없음"
    $0.font = .appFont(family: .pretendard(option: .regular), size: 14)
    $0.textColor = .mediumGray
  }
  
  private let button = UIButton().then {
    $0.showsMenuAsPrimaryAction = true
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
    [label, imageView, button].forEach {
      addSubview($0)
    }
  }

  private func setupConstraints() {
    imageView.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(12.5)
      $0.centerY.equalToSuperview()
      $0.width.equalTo(19)
      $0.height.equalTo(25)
    }
    
    label.snp.makeConstraints {
      $0.trailing.equalTo(imageView.snp.leading).offset(-6)
      $0.centerY.equalTo(imageView.snp.centerY)
    }
    
    button.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  private func setupStyles() {
    setupButtonMenus()
  }
}

extension ScheduleAlarmView {
  private func setupButtonMenus() {
    let menuItems = ScheduleAlarmType.allCases
      .map { alarm in
        return UIAction(title: alarm.rawValue, image: nil) { [weak self] _ in
          guard let self else { return }
          self.setupAlarmText(with: alarm)
          self.delegate?.selectAlarm(alarm: alarm)
        }
      }
    
    button.menu = UIMenu(
      title: "",
      image: nil,
      identifier: nil,
      options: [],
      children: menuItems
    )
  }
  
  private func setupAlarmText(with alarm: ScheduleAlarmType) {
    label.text = alarm.rawValue
    if alarm == .none {
      label.textColor = .mediumGray
    } else {
      label.textColor = .black
    }
  }
}
