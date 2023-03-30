//
//  TodoAlertViewController.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/30.
//

import UIKit

import SnapKit
import Then

final class TodoAlertController: BaseViewController {
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
  }
  
  private let profileImageView = UIImageView().then {
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 12
    $0.image = UIImage(systemName: "person.fill")
  }
  
  private let dateLabel = UILabel().then {
    $0.font = .overLine
    $0.textColor = .black
    $0.text = "11.06 (오늘)"
  }
  
  private let nameLabel = UILabel().then {
    $0.font = .caption2
    $0.textColor = .black
    $0.text = "미나리"
  }
  
  private let closeButton = UIButton().then {
    $0.setImage(UIImage(named: "xMarkDeepGray"), for: .normal)
  }
  
  private let seperatorView = UIView().then {
    $0.backgroundColor = .lightGray
  }
  
  private let nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.detailRecruitment(label: "나중에 할게요!")
    $0.isSelected = false
  }
  
  private let completedButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.detailRecruitment(label: "완료!")
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .black
    view.alpha = 0.45
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(containerView)
    [profileImageView, dateLabel, nameLabel, seperatorView, nextButton, completedButton].forEach { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    containerView.snp.makeConstraints {
      $0.directionalHorizontalEdges.equalToSuperview().inset(32)
      $0.height.equalTo(376)
      $0.center.equalToSuperview()
    }
    
    profileImageView.snp.makeConstraints {
      $0.size.equalTo(24)
      $0.top.leading.equalToSuperview().inset(16)
    }
    
    dateLabel.snp.makeConstraints {
      $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
      $0.top.equalToSuperview().inset(14)
    }
    
    nameLabel.snp.makeConstraints {
      $0.top.equalTo(dateLabel.snp.bottom)
      $0.leading.equalTo(dateLabel)
    }
  }
}
