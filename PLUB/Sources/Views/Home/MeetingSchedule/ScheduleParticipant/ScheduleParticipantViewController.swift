//
//  ScheduleParticipantViewController.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/05.
//

import UIKit

import SnapKit
import Then

final class ScheduleParticipantViewController: BottomSheetViewController {
  
  private let data: ScheduleTableViewCellModel
  
  private let lineView = UIView().then {
    $0.backgroundColor = .mediumGray
    $0.layer.cornerRadius = 2
  }
  
  private lazy var topScheduleView = ScheduleParticipantTopView(data: data)
  
  private let viewModel = ScheduleParticipantViewModel()
  
  init(data: ScheduleTableViewCellModel) {
    self.data = data
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [lineView, topScheduleView].forEach {
      contentView.addSubview($0)
    }
  }
  
  override func setupConstraints() {
    super.setupConstraints()

    
    lineView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(8)
      $0.height.equalTo(4)
      $0.width.equalTo(48)
      $0.centerX.equalToSuperview()
    }
    
    topScheduleView.snp.makeConstraints {
      $0.top.equalTo(lineView.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.bottom.equalToSuperview().inset(8)
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
  }
  
  override func bind() {
    super.bind()
  }
}
