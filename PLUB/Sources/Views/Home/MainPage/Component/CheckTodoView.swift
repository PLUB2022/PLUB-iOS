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
  func didTappedCheckboxButton(todoID: Int, isCompleted: Bool, todo: String)
}

struct CheckTodoViewModel {
  let todoID: Int
  let todo: String
  let isChecked: Bool
  let isAuthor: Bool
  var isProof: Bool
}

final class CheckTodoView: UIView {
  
  weak var delegate: CheckTodoViewDelegate?
  private var model: CheckTodoViewModel?
  private var isChecked: Bool = false {
    didSet {
      if isChecked {
        todoLabel.attributedText = todoLabel.text?.strikeThrough()
      } else {
        todoLabel.attributedText = NSAttributedString(string: todoLabel.text ?? "")
      }
      checkboxButton.isChecked = isChecked
    }
  }
  
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
      .subscribe(with: self) { owner, isChecked in
        guard let model = owner.model else { return }
        owner.isChecked = isChecked
        if model.isAuthor && !model.isProof { // 내가 작성했고 인증되있지않은 투두만 완료/인증 가능
          owner.delegate?.didTappedCheckboxButton(todoID: model.todoID, isCompleted: owner.checkboxButton.isChecked, todo: model.todo)
        }
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
    self.model = model
    todoLabel.text = model.todo
    self.isChecked = model.isChecked || model.isProof
    
    // 해당 투두가 인증되었거나 작성자가 아니라면 -> 체크버튼 비활성화
    checkboxButton.isEnabled = model.isProof || !model.isAuthor ? false : true
    
  }
}
