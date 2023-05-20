//
//  TodoListView.swift
//  PLUB
//
//  Created by 김수빈 on 2023/04/29.
//

import UIKit

import SnapKit
import Then
import RxSwift

protocol TodoListViewDelegate: AnyObject {
  func didTappedCheckButton(todo: Todo)
}

final class TodoListView: UIView {
  private let checkButton = CheckBoxButton(type: .full)
  private let todo: Todo
  private let disposeBag = DisposeBag()
  weak var delegate: TodoListViewDelegate?
  
  private let todoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .body2
  }
  
  init(todo: Todo) {
    self.todo = todo
    super.init(frame: .zero)
    setupLayouts()
    setupConstraints()
    bind()
    setupData(todo: todo)
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
  
  private func bind() {
    checkButton.rx.tap
      .subscribe(with: self) { owner, _ in
        owner.delegate?.didTappedCheckButton(todo: owner.todo)
      }
      .disposed(by: disposeBag)
  }
  
  private func setupData(todo: Todo) {
    let attributeString: NSAttributedString
    if todo.isChecked {
      attributeString = NSAttributedString(
        string: todo.content,
        attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
      )
    } else {
      attributeString = NSAttributedString(string: todo.content)
    }
    todoLabel.attributedText = attributeString
    
    checkButton.isChecked = todo.isChecked
  }
}
