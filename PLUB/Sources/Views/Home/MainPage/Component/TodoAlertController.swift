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
  
  private let dimmedView = UIView().then {
    $0.backgroundColor = .black.withAlphaComponent(0.45)
  }
  
  private let containerView = UIView().then {
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.cornerRadius = 10
    $0.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
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
  
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 12
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 23.8, left: 16, bottom: 17, right: 16)
  }
  
  private let nextButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.detailRecruitment(label: "나중에 할게요!")
  }
  
  private let completedButton = UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.detailRecruitment(label: "완료!")
    $0.isSelected = true
  }
  
  private let tapGesture = UITapGestureRecognizer(target: TodoAlertController.self, action: nil)
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // curveEaseOut: 시작은 천천히, 끝날 땐 빠르게
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut) { [weak self] in
      self?.containerView.transform = .identity
      self?.containerView.isHidden = false
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // curveEaseIn: 시작은 빠르게, 끝날 땐 천천히
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn) { [weak self] in
      self?.containerView.transform = .identity
      self?.containerView.isHidden = true
    }
  }
  
  override func setupStyles() {
    super.setupStyles()
    view.backgroundColor = .clear
    dimmedView.addGestureRecognizer(tapGesture)
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [dimmedView, containerView].forEach { view.addSubview($0) }
    [profileImageView, dateLabel, nameLabel, seperatorView, buttonStackView].forEach { containerView.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    dimmedView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
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
    
    [nextButton, completedButton].forEach { buttonStackView.addArrangedSubview($0) }
    buttonStackView.snp.makeConstraints {
      $0.bottom.directionalHorizontalEdges.equalToSuperview()
      $0.height.equalTo(46 + 17 + 23.8)
    }
  }
  
  override func bind() {
    super.bind()
    
    tapGesture.rx.event
      .subscribe(with: self) { owner, _ in
        owner.dismiss(animated: false)
      }
      .disposed(by: disposeBag)
  }
}
