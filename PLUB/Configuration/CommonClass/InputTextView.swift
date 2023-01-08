//
//  InputTextView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/01/08.
//

import SnapKit
import UIKit

final class InputTextView: UIView {
  
  // MARK: - Property
  
  private let stackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 8
  }
  
  private let titleView = UIView()
  
  private let titleLabel = UILabel().then {
    $0.font = .subtitle
  }
  
  private let questionButton = UIButton().then {
    $0.setImage(UIImage(named: "questionButton"), for: .normal)
  }
  
  let textView = UITextView().then {
    $0.textColor = .deepGray
    $0.textContainerInset = UIEdgeInsets(
      top: 14,
      left: 8,
      bottom: 14,
      right: 8
    )
    $0.font = .body2
    $0.backgroundColor = .white
    $0.layer.cornerRadius = 8
    $0.isScrollEnabled = false
  }
  
  let countTextLabel = UILabel().then {
    $0.font = .overLine
    $0.textAlignment = .right
  }
  
  init(
    title: String,
    placeHolder: String,
    option: InputTextOption = InputTextOption(
      textCount: false,
      questionOption: false
      )
  ) {
    super.init(frame: .zero)
    
    titleLabel.text = title
    textView.text = placeHolder
    setupLayouts(option: option)
    setupConstraints(option: option)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts(option: InputTextOption) {
    addSubview(stackView)
    
    let stackViewSubviews = [
      titleView,
      textView,
      option.textCount ? countTextLabel : nil
    ].compactMap { $0 }
    
    stackViewSubviews.forEach {
      stackView.addArrangedSubview($0)
    }
    
    let titleStackViewSubviews = [
      titleLabel,
      option.questionOption ? questionButton : nil
    ].compactMap { $0 }
    
    titleStackViewSubviews.forEach {
      titleView.addSubview($0)
    }
  }
  
  private func setupConstraints(option: InputTextOption) {
    stackView.snp.makeConstraints{
      $0.top.bottom.equalToSuperview()
      $0.leading.trailing.equalToSuperview().inset(16)
    }
    
    titleView.snp.makeConstraints {
      $0.height.equalTo(19)
    }
    
    titleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview()
    }
    
    if option.questionOption {
      questionButton.snp.makeConstraints {
        $0.size.equalTo(12)
        $0.centerY.equalTo(titleLabel.snp.centerY)
        $0.leading.equalTo(titleLabel.snp.trailing).offset(6)
      }
    }
    
    textView.snp.makeConstraints {
      $0.height.equalTo(46)
    }
    
    if option.textCount {
      countTextLabel.snp.makeConstraints {
        $0.height.equalTo(12)
      }
      stackView.setCustomSpacing(4, after: textView)
    }
  }
}

struct InputTextOption {
  let textCount: Bool // 글자수 세기
  let questionOption: Bool // 물음표 버튼
}
