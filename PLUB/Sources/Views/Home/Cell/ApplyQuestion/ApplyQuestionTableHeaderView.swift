//
//  ApplyQuestionTableViewHeader.swift
//  PLUB
//
//  Created by 이건준 on 2023/01/04.
//

import UIKit

import SnapKit
import Then

class ApplyQuestionTableHeaderView: UITableViewHeaderFooterView {
  
  static let identifier = "ApplyQuestionTableHeaderView"
  
  private let mainLabel = UILabel().then {
    $0.font = .h4
    $0.textColor = .black
    $0.textAlignment = .left
  }
  
  private let subLabel = UILabel().then {
    $0.numberOfLines = 0
    $0.font = .body2
    $0.textColor = .deepGray
    $0.textAlignment = .left
    $0.sizeToFit()
    //        $0.isHidden = true
  }
  
  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [mainLabel, subLabel].forEach { contentView.addSubview($0) }
    mainLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.left.right.equalToSuperview().inset(20)
      $0.height.equalTo(24)
    }
    
    subLabel.snp.makeConstraints {
      $0.top.equalTo(mainLabel.snp.bottom)
      $0.left.right.equalTo(mainLabel)
    }
  }
  
  public func configureUI(with model: String) {
    mainLabel.text = "함께 하기 위한 질문"
    subLabel.text = "우리와 함께 하는 것에 대한 질문입니다. 상세하게 적어줄 수록 당신의 취미 레벨을 선정하기 쉬워집니다. "
  }
}
