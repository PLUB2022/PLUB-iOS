//
//  RecruitingHeaderView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/16.
//

import UIKit

import SnapKit
import RxSwift

extension PlubbingStatusType {
  var subtitle: String {
    switch self {
    case .recruiting:
       return "지원자 내역"
    case .end:
      return ""
    case .active:
      return ""
    case .waiting:
      return "나의 지원서"
    }
  }
}

final class RecruitingHeaderView: UIView {
  private let disposeBag = DisposeBag()
  
  private let contentStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 16
  }
  
  private let titleLabel = UILabel().then {
    $0.font = .h2
    $0.textColor = .black
  }
  
  private let scheduleView = ScheduleDetailContentView(type: .date)
  private let locationView = ScheduleDetailContentView(type: .location)
  
  private let subtitleLabel = UILabel().then {
    $0.font = .h5
    $0.textColor = .black
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

extension RecruitingHeaderView {
  private func setupLayouts() {
    addSubview(contentStackView)
    
    [titleLabel, scheduleView, locationView, subtitleLabel].forEach {
      contentStackView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    contentStackView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(24)
      $0.leading.equalToSuperview().inset(16)
      $0.trailing.equalToSuperview().inset(155)
      $0.bottom.equalToSuperview().inset(15)
    }
    
    titleLabel.snp.makeConstraints {
      $0.height.equalTo(33)
    }
    
    [scheduleView, locationView].forEach {
      $0.snp.makeConstraints {
        $0.height.equalTo(17)
      }
    }
    
    subtitleLabel.snp.makeConstraints {
      $0.height.equalTo(23)
    }
    
    contentStackView.setCustomSpacing(8, after: scheduleView)
    contentStackView.setCustomSpacing(41, after: locationView)
  }
  
  private func setupStyles() {
  }
  
  func setupData(with data: RecruitingModel, type: PlubbingStatusType) {
    titleLabel.text = data.title
    if data.address.isEmpty {
      locationView.isHidden = true
      locationView.snp.updateConstraints {
        $0.height.equalTo(0)
      }
      contentStackView.setCustomSpacing(41, after: scheduleView)
    } else {
      locationView.setText(data.address, false)
    }
    scheduleView.setText(data.schedule, false)
    subtitleLabel.text = type.subtitle
  }
}
