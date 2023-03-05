//
//  ScheduleParticipantViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/05.
//

import UIKit

import SnapKit
import Then

class ScheduleParticipantViewController: BottomSheetViewController {
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 2
  }
  
  private let contentStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 14
  }
  
  init(model: MeetingScheduleData) {
    self.model = model
    super.init(nibName: nil, bundle: nil)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [lineView, contentStackView].forEach {
      contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview().inset(8)
      $0.height.equalTo(4.33)
      $0.width.equalTo(52)
      $0.centerX.equalToSuperview()
    }
    
    contentStackView.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(16)
      $0.directionalEdges.equalToSuperview().inset(24)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}
