//
//  CheckTodoView.swift
//  PLUB
//
//  Created by 이건준 on 2023/03/29.
//

import UIKit

import RxSwift
import SnapKit
import Then

protocol CheckTodoViewDelegate: AnyObject {
  func didTappedCheckboxButton(todoID: Int, isCompleted: Bool)
}

struct CheckTodoViewModel {
  let todoID: Int
  let todo: String
  let isChecked: Bool
}

final class CheckTodoView: UIView {
  
  weak var delegate: CheckTodoViewDelegate?
  private var todoID: Int?
  private let disposeBag = DisposeBag()
  
  private let checkboxButton = CheckBoxButton(type: .none)
  
  private let todoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
    bind()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func bind() {
    checkboxButton.rx.isChecked
      .subscribe(with: self) { owner, _ in
        guard let todoID = owner.todoID else { return }
        owner.delegate?.didTappedCheckboxButton(todoID: todoID, isCompleted: owner.checkboxButton.isChecked)
      }
      .disposed(by: disposeBag)
  }
  
  private func configureUI() {
    [checkboxButton, todoLabel].forEach { addSubview($0) }
    checkboxButton.snp.makeConstraints {
      $0.directionalVerticalEdges.leading.equalToSuperview().inset(6)
      $0.size.equalTo(12)
    }
    
    todoLabel.snp.makeConstraints {
      $0.leading.equalTo(checkboxButton.snp.trailing).offset(14)
      $0.directionalVerticalEdges.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }
  }
  
  func configureUI(with model: CheckTodoViewModel) {
    self.todoID = model.todoID
    todoLabel.text = model.todo
    checkboxButton.isChecked = model.isChecked
  }
}
