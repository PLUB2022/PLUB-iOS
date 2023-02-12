//
//  RegisterInterestHeaderView.swift
//  PLUB
//
//  Created by 이건준 on 2022/10/10.
//

import UIKit

import SnapKit
import Then

final class RegisterInterestHeaderView: UIView {
  
  private let titleLabel = UILabel().then {
    $0.font = .h4
    $0.textColor = .black
  }
  
  private let descriptionLabel = UILabel().then {
    $0.font = .body2
    $0.textColor = .black
    $0.numberOfLines = 0
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [titleLabel, descriptionLabel].forEach { addSubview($0) }
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.leading.equalTo(titleLabel.snp.leading)
      $0.top.equalTo(titleLabel.snp.bottom).offset(4)
      $0.height.equalTo(self.snp.height).dividedBy(2)
    }
    
    titleLabel.text = "취미모임 관심사 등록"
    descriptionLabel.text = "PLUB 에게 당신의 관심사를 알려주세요.\n관심사 위주로 모임을 추천해 드려요!"
  }
}
