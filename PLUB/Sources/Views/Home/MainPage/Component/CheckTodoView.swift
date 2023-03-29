//
//  CheckTodoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/29.
//

import UIKit

import SnapKit
import Then

class CheckTodoView: UIView {
  
  private let checkboxButton = CheckBoxButton(type: .none)
  
  private let todoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
    $0.text = "독후감 쓴 내용 팀원들이랑 공유하기"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [checkboxButton, todoLabel].forEach { addSubview($0) }
    checkboxButton.snp.makeConstraints {
      $0.directionalVerticalEdges.leading.equalToSuperview().inset(8)
      $0.size.equalTo(24)
    }
    
    todoLabel.snp.makeConstraints {
      $0.leading.equalTo(checkboxButton.snp.trailing).offset(8)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
}
