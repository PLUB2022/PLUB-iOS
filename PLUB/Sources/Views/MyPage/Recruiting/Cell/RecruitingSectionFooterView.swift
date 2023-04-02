//
//  RecruitingSectionFooterView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/03/18.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

enum ApplicationType {
  case recruiting
  case waiting(questionCount: Int)
  
  var firstButtonTitle: String {
    switch self {
    case .recruiting:
      return "거절하기"
    case .waiting:
      return "지원 취소"
    }
  }
  
  var secondButtonTitle: String {
    switch self {
    case .recruiting:
      return "받기"
    case .waiting:
      return "수정"
    }
  }
}

protocol RecruitingSectionFooterViewDelegate: AnyObject {
  func firstButtonTapped(sectionIndex: Int)
  func secondButtonTapped(sectionIndex: Int)
}

final class RecruitingSectionFooterView: UITableViewHeaderFooterView {
  static let identifier = "RecruitingSectionFooterView"
  weak var delegate: RecruitingSectionFooterViewDelegate?
  private let disposeBag = DisposeBag()
  private var sectionIndex: Int? = nil
  private var applicationType: ApplicationType? = nil
  
  private let containerView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 0
  }
  
  private let clearView = UIView().then {
    $0.backgroundColor = .clear
  }
  
  private let whiteView = UIView().then {
    $0.backgroundColor = .white
  }
 
  private let buttonStackView = UIStackView().then {
    $0.axis = .horizontal
    $0.spacing = 8
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    $0.backgroundColor = .white
    $0.distribution = .fillEqually
  }
  
  private let firstButton = UIButton(configuration: .plain()).then {
    $0.configuration?.font = .button
    $0.configuration?.background.backgroundColor = .lightGray
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.baseForegroundColor = .deepGray
  }
  
  private let secondButton =  UIButton(configuration: .plain()).then {
    $0.configuration?.font = .button
    $0.configuration?.background.backgroundColor = .main
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.baseForegroundColor = .white
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setupLayouts()
    setupConstraints()
    setupStyles()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    buttonStackView.subviews.forEach { $0.removeFromSuperview() }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    containerView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 15)
    containerView.layer.addBorder([.bottom], color: .lightGray, width: 1)
  }
  
  private func setupLayouts() {
    addSubview(containerView)
    
    [clearView, buttonStackView, whiteView].forEach {
      containerView.addArrangedSubview($0)
    }
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.equalToSuperview().offset(-8)
      $0.bottom.equalToSuperview()
    }
    
    clearView.snp.makeConstraints {
      $0.height.equalTo(8)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.height.equalTo(46)
    }
  }
  
  private func setupStyles() {
  }
  
  private func bind() {
    firstButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let sectionIndex = owner.sectionIndex else { return }
        owner.delegate?.firstButtonTapped(sectionIndex: sectionIndex)
      }
      .disposed(by: disposeBag)
    
    secondButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let sectionIndex = owner.sectionIndex else { return }
        owner.delegate?.secondButtonTapped(sectionIndex: sectionIndex)
      }
      .disposed(by: disposeBag)
  }
  
  func setupData(sectionIndex: Int, type: ApplicationType) {
    self.sectionIndex = sectionIndex
    self.applicationType = type
  
    firstButton.configuration?.title = type.firstButtonTitle
    firstButton.configuration?.font = .button

    secondButton.configuration?.title = type.secondButtonTitle
    secondButton.configuration?.font = .button
    
    buttonStackView.addArrangedSubview(firstButton)
    
    switch type {
    case .waiting(questionCount: let questionCount):
      if questionCount != 0 {
        buttonStackView.addArrangedSubview(secondButton)
      }
    case .recruiting:
      buttonStackView.addArrangedSubview(secondButton)
    }
  }
}
