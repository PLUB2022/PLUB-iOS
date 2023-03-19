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

protocol RecruitingSectionFooterViewDelegate: AnyObject {
  func declineApplicant(sectionIndex: Int)
  func acceptApplicant(sectionIndex: Int)
}

final class RecruitingSectionFooterView: UITableViewHeaderFooterView {
  static let identifier = "RecruitingSectionFooterView"
  weak var delegate: RecruitingSectionFooterViewDelegate?
  private let disposeBag = DisposeBag()
  private var sectionIndex: Int? = nil
  
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
  }
  
  private let declineButton = UIButton(configuration: .plain()).then {
    $0.configuration?.title = "거절하기"
    $0.configuration?.font = .button
    $0.configuration?.background.backgroundColor = .lightGray
    $0.configuration?.background.cornerRadius = 10
    $0.configuration?.baseForegroundColor = .deepGray
  }
  
  private let acceptButton =  UIButton(configuration: .plain()).then {
    $0.configurationUpdateHandler = $0.configuration?.plubButton(label: "받기")
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
    
    [declineButton, acceptButton].forEach {
      buttonStackView.addArrangedSubview($0)
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
    declineButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let sectionIndex = owner.sectionIndex else { return }
        owner.delegate?.declineApplicant(sectionIndex: sectionIndex)
      }
      .disposed(by: disposeBag)
    
    acceptButton.rx.tap
      .asDriver()
      .drive(with: self) { owner, _ in
        guard let sectionIndex = owner.sectionIndex else { return }
        owner.delegate?.acceptApplicant(sectionIndex: sectionIndex)
      }
      .disposed(by: disposeBag)
  }
  
  func setupData(sectionIndex: Int) {
    self.sectionIndex = sectionIndex
  }
}
