//
//  TodoListView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/29.
//

import UIKit

import SnapKit
import Then

final class TodoListView: UIView {
  private let checkButton = CheckBoxButton(type: .full)
  
  private let todoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body2
    $0.text = "독후감 쓴 내용 팀원들이랑 공유하기"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupLayouts()
    setupConstraints()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setupLayouts() {
    [checkButton, todoLabel].forEach {
      addSubview($0)
    }
  }
  
  private func setupConstraints() {
    checkButton.snp.makeConstraints {
      $0.size.equalTo(12)
      $0.centerY.equalToSuperview()
      $0.leading.top.bottom.equalToSuperview().inset(6)
    }
    
    todoLabel.snp.makeConstraints {
      $0.centerY.equalTo(checkButton.snp.centerY)
      $0.leading.equalTo(checkButton.snp.trailing).offset(14)
      $0.trailing.equalToSuperview()
    }
  }
}
