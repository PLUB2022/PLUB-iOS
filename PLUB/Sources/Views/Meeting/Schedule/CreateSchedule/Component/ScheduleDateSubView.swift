//
//  ScheduleDateSubView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/02/18.
//

import UIKit

import SnapKit
import RxCocoa
import RxSwift

enum MeetingScheduleDateType: String, CaseIterable {
  case allDay = "하루 종일"
  case start = "시작"
  case end = "종료"
  
  var componetType: DateComponetType {
    switch self {
    case .allDay:
      return .toggle
    case .start, .end:
      return .datePicker
    }
  }
  
  enum DateComponetType {
    case toggle
    case datePicker
  }
}

final class ScheduleDateSubView: UIView {
  private let dateType: MeetingScheduleDateType
  
  private lazy var label = UILabel().then {
    $0.text = dateType.rawValue
    $0.font = UIFont.appFont(family: .pretendard(option: .semiBold), size: 14)
  }
  
  private let lineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  init(type: MeetingScheduleDateType) {
    dateType = type
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    addSubview(label)
  
    switch dateType {
    case .allDay, .start:
      addSubview(lineView)
    case .end:
      break
    }
  }

  private func setupConstraints() {
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(12.5)
      $0.centerY.equalToSuperview()
      $0.height.equalTo(22)
      $0.top.bottom.equalToSuperview().inset(12.5)
    }
    
    switch dateType {
    case .allDay, .start:
      lineView.snp.makeConstraints {
        $0.leading.equalTo(label.snp.leading)
        $0.bottom.trailing.equalToSuperview()
        $0.height.equalTo(1)
      }
    case .end:
      break
    }
  }
}

extension ScheduleDateSubView {
  func addDateSubview(_ object: UIView) {
    addSubview(object)
    object.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().inset(12)
    }
  }
}
