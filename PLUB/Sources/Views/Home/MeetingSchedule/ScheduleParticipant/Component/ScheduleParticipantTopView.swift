//
//  ScheduleParticipantTopView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/05.
//

import UIKit

import SnapKit
import Then
import RxCocoa
import RxSwift

final class ScheduleParticipantTopView: UIView {

  private let contentStackView = UIStackView().then {
    $0.spacing = 14
    $0.axis = .horizontal
  }
  
  // 날짜
  private let dateView = UIView().then {
    $0.backgroundColor = .main2
    $0.layer.cornerRadius = 10
  }
  
  private let dateStackView = UIStackView().then {
    $0.spacing = 0
    $0.axis = .vertical
  }
  
  private let monthLabel = UILabel().then {
    $0.font = .body1
    $0.textColor = .main
  }
  
  private let dayLabel = UILabel().then {
    $0.font = .h2
    $0.textColor = .main
  }
  
  // 제목, 시간, 장소
  private let subContentStackView = UIStackView().then {
    $0.spacing = 8
    $0.axis = .vertical
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .h4
    $0.textColor = .black
  }
  
  private let timeView = ScheduleDetailContentView(type: .time)
  private let locationView = ScheduleDetailContentView(type: .location)
  
  // 하단 선
  private let lineView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  init(data: ScheduleTableViewCellModel) {
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    setupData(with: data)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupLayouts() {
    [contentStackView, lineView].forEach {
      addSubview($0)
    }
    
    [dateView, subContentStackView].forEach {
      contentStackView.addArrangedSubview($0)
    }
    
    dateView.addSubview(dateStackView)
    
    [monthLabel, dayLabel].forEach {
      dateStackView.addArrangedSubview($0)
    }
    
    [titleLabel, timeView, locationView].forEach {
      subContentStackView.addArrangedSubview($0)
    }
    
    subContentStackView.setCustomSpacing(4, after: timeView)
  }

  private func setupConstraints() {
    contentStackView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(71)
    }
    
    dateView.snp.makeConstraints {
      $0.size.equalTo(71)
    }
    
    dateStackView.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    monthLabel.snp.makeConstraints {
      $0.height.equalTo(21)
    }
    
    dayLabel.snp.makeConstraints {
      $0.height.equalTo(34)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(24)
    }
    
    [timeView, locationView].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(16)
      }
    }
    
    lineView.snp.makeConstraints {
      $0.top.equalTo(contentStackView.snp.bottom).offset(13)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(1)
      $0.bottom.equalToSuperview()
    }
  }
  
  private func setupData(with data: ScheduleTableViewCellModel) {
    // 날짜
    monthLabel.text = "\(data.month)월"
    dayLabel.text = "\(data.day)일"
    
    // 이름
    titleLabel.text = data.name
    titleLabel.textColor = data.isPasted ? .deepGray : .black
    
    // 시간
    timeView.setText(data.time, data.isPasted)
    
    // 장소
    if let location = data.location, !location.isEmpty {
      locationView.setText(location, data.isPasted)
      locationView.snp.updateConstraints {
        $0.height.equalTo(21)
      }
    } else {
      locationView.setText(nil, data.isPasted)
      locationView.snp.updateConstraints {
        $0.height.equalTo(0)
      }
    }
  }
}
