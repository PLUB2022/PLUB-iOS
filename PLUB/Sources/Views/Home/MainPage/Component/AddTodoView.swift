//
//  AddTodoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/05/08.
//

import UIKit

import SnapKit
import Then

final class TodoView: UIView {
  
  private let emptyCheckView = UIView().then {
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.gray.cgColor
    $0.layer.cornerRadius = 3
    $0.layer.masksToBounds = true
  }
  
  private let todoTextField = UITextField().then {
    $0.placeholder = "새로운 TO-DO 추가하기"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    [emptyCheckView, todoTextField].forEach { addSubview($0) }
    
    emptyCheckView.snp.makeConstraints {
      $0.size.equalTo(18)
      $0.leading.directionalVerticalEdges.equalToSuperview().inset(7)
    }
    
    todoTextField.snp.makeConstraints {
      $0.leading.equalTo(emptyCheckView.snp.trailing).offset(7)
      $0.directionalVerticalEdges.trailing.equalToSuperview()
    }
  }
}

final class AddTodoView: UIView {
  
  private let todoContainerView = UIStackView().then {
    $0.axis = .vertical
    $0.isLayoutMarginsRelativeArrangement = true
    $0.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
    $0.spacing = 10
  }
  
  private let dateLabel = UILabel().then {
    $0.textColor = .main
    $0.font = .h5
    $0.text = "04.05(오늘)"
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func configureUI() {
    addSubview(todoContainerView)
    
    todoContainerView.snp.makeConstraints {
      $0.top.directionalHorizontalEdges.equalToSuperview()
      $0.bottom.equalToSuperview()
    }
    
    todoContainerView.addArrangedSubview(dateLabel)
    
    let todoView = TodoView()
    todoContainerView.addArrangedSubview(todoView)
  }
}
