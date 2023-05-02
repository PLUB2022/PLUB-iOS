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
  func didTappedCheckboxButton()
}

struct CheckTodoViewModel {
  let todo: String
  let isChecked: Bool
}

final class CheckTodoView: UIView {
  
  weak var delegate: CheckTodoViewDelegate?
  private let disposeBag = DisposeBag()
  
  private let checkboxButton = CheckBoxButton(type: .none)
  
  private let todoLabel = UILabel().then {
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 14)
    $0.text = "독후감 쓴 내용 팀원들이랑 공유하기"
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
        owner.delegate?.didTappedCheckboxButton()
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
    todoLabel.text = model.todo
    checkboxButton.isChecked = model.isChecked
  }
}
