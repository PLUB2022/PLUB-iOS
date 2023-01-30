//
//  ApplyQuestionTableViewHeader.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit

import SnapKit
import Then

class ApplyQuestionHeaderView: UIView {
  
  var isActive: Bool = false {
    didSet {
      subLabel.isHidden = !isActive
    }
  }
  
  private let mainLabel = UILabel().then {
    $0.font = .h4
    $0.textColor = .black
    $0.textAlignment = .left
    $0.text = "함께 하기 위한 질문"
  }
  
  private let subLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .body2
    $0.textColor = .deepGray
    $0.textAlignment = .left
    $0.sizeToFit()
    $0.text = "우리와 함께 하는 것에 대한 질문입니다. 상세하게 적어줄 수록 당신의 취미 레벨을 선정하기 쉬워집니다. "
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [mainLabel, subLabel].forEach { addSubview($0) }
    mainLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.right.equalToSuperview().inset(20)
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(mainLabel.snp.bottom)
      $0.left.right.equalTo(mainLabel)
      $0.bottom.equalToSuperview()
    }
  }
}
